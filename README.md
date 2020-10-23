
# split-log Docker Image
Builds of this image can be found in https://hub.docker.com/repository/docker/torsstei/split-log.

This docker image runs a batch job to download large log archives from COS, uncompresses and splits them into files with a customizable number of lines, recompresses them (using a compression codex other than gzip so that the compressed data can be read in parallel by e.g. Spark) and finally uploads them to a COS location of your choice.

The job can run in any docker environment but it is meant to be deployed in [IBM Cloud Code Engine](https://www.ibm.com/cloud/blog/announcements/ibm-cloud-code-engine?_ga=2.63441191.966808581.1603006777-504646121.1603006777) to run close to the COS data. Through the support of using private COS endpoints in IBM Cloud this allows you to perform the entire split operation for a 1 GB of compressed log archive in about one minute.

## Building the image
```
docker build --tag split-log .
```

## Parameters

 - ACCESSKEY: Your COS HMAC access key
 - SECRETKEY: Your COS HMAC secret access key
 - REGION: The region of your json.gz file on COS
 - BUCKET: The COS bucket name of your json.gz file
 - FILENAME: The name of your json.gz file on COS (when it is in a virtual folder you must specify it as PREFIX variable)
 - PREFIX: The optional prefix name of your json.gz file (optional, default is empty string)
 - LINES: The number of lines in each split file (optional, default is 100000)
 - TARGETREGION: The region of your target split files on COS (optional, default is same value as REGION)
 - TARGETBUCKET: The bucket of your target split files on COS (optional, default is same value as BUCKET)
 - TARGETPREFIX: The prefix of your target split files on COS (optional, default is same value as PREFIX)
 - TARGETACCESSKEY: Your COS HMAC access key for your target COS bucket (optional, default is same value as ACCESSKEY)
 - TARGETSECRETKEY: Your COS HMAC secret access key for your target COS bucket (optional, default is same value as SECRETKEY)
 - PRIVATE_ENDPOINTS: When set to a value the access to COS is performed using direct private endpoint of IBM Cloud (default is: not set)

#### Getting COS HMAC credentials

The split-log job uses HMAC credentials to read and write from COS. You provide them to the job using paramters ACCESSKEY and SECRETKEY (and in case the COS target bucket is in a different COS instance also in additional parameters TARGETACCESSKEY and TARGETSECRETKEY).

If you don't have such credentials created for your COS instance(s) the following shows how you can do that.

Identify the instance name of your COS instance:
```
ibmcloud resource service-instances --long | grep cloud-object-storage
```

Create new credentials for your COS instance, incljuding HMAC credentials:
```
ibmcloud resource service-key-create my_creds_with_hmac Writer --instance-name "<the name of your COS instance>" --parameters '{"HMAC":true}'
```
In the command output you can see the `access_key_id` and `secret_access_key` values.

You can at any later point retrieve the credentials again using:
```
ibmcloud resource service-key my_creds_with_hmac
```


## Running with plain docker

```shell
docker run -e ACCESSKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -e SECRETKEY='asASfasfasdFasdf4qr22Fsdsdfwert4dssdfwf343fsdfsdghsSDGSDGdsg' -e NUMBER_OF_LINES='100000' -e FILENAME='a591844d24.2019-07-17.72.json.gz' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/' split-log
```

This downloads an object named test.json.gz from bucket `mybucket` in region `us-geo`, splits it into multiple files with each 100000 lines and compresses them with bzip2 and then uploads these to same region and bucket as object names `split/a591844d24.2019-07-17.72.xaaaaa.json.bz`, `split/.a591844d24.2019-07-17.72.xaaaab.json.bz` etc.

## Running with IBM Cloud Code Engine

You can run the split-log as a serverless job in IBM Cloud Code Engine. For that you need to build it as a docker image and push it to Docker Hub. If you don't want to build and push it yourself you can also use the published image in https://hub.docker.com/repository/docker/torsstei/split-log.

#### CLI Setup

Make sure you have **ibmcloud** CLI installed. If not, refer [here](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli).

Make sure you have the [Code Engine plugin](https://cloud.ibm.com/codeengine/cli) installed for the CLI.

#### Code Engine Setup

If you haven't used Code Engine in your account before log in configure the ibmcloud CLI as described [here](https://cloud.ibm.com/docs/codeengine?topic=codeengine-install-cli).

Make sure you are working in the region where also your COS bucket data is located. This is not mandatory, but it is important to achieve best performance for the log-split job. Setting region us-south can be achieved like this:
```
ibmcloud target -r us-south
```

Now create a Code Engine project:
```
ibmcloud ce project create --name myproject --select
```

#### Running the Job

Create a job definition for using the split-log docker image:
```
ibmcloud ce job create --name my-split-log-job --image docker.io/torsstei/split-log:latest -e ACCESSKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -e SECRETKEY='asASfasfasdFasdf4qr22Fsdsdfwert4dssdfwf343fsdfsdghsSDGSDGdsg' -e NUMBER_OF_LINES='100000' -e FILENAME='a591844d24.2019-07-17.72.json.gz' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/' -e PRIVATE_ENDPOINTS='true'
```
Note that we set environment parameter PRIVATE_ENDPOINTS because we want to use private IBM Cloud endpoints when reading and writing COS while running inside IBM Cloud Code Engine. This allows to achieve machimum I/O performance, resulting in splitting a 1 GB log archive in about one minute.

Submit the job:
```
ibmcloud ce jobrun submit --job my-split-log-job
```
You'll get an output like this:
```
Getting job 'my-split-log-job'...
Submitting job run 'my-split-log-job-jobrun-prkks'...
OK
```
This tells you the pod name in Code Engine that runs your job (`my-split-log-job-jobrun-prkks` in this case).

Check the status of the pod:
```
ibmcloud ce jobrun get --name my-split-log-job-jobrun-prkks
```
At the end of the output you can see the pod execution events like this:
```
Instances:    
  Name                               Running  Status     Restarts  Age  
  my-split-log-job-jobrun-prkks-0-0  0/1      Succeeded  0         3d21h  
```
In that output you find the pod instance name (in this case `my-split-log-job-jobrun-prkks-0-0`).

Get the logs of the pod instance:
```
ibmcloud ce jobrun logs --instance my-split-log-job-jobrun-prkks-0-0
```

##### Optional

In case you want to get more detailed information about the pods it might be useful to use `kubectl` command. You do this by first setting up the kubecfg for your code engine project:
```
ibmcloud ce project select --name myproject --kubecfg
```

Now you could for instance get the details of a pod with:
```
kubectl describe pod my-split-log-job-jobrun-prkks
```

Or you could get the logs for a pod instance with:
```
kubectl logs my-split-log-job-jobrun-prkks-0-0
```
