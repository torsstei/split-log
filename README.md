
# split-log Docker Image
Builds of this image can be found in https://hub.docker.com/repository/docker/torsstei/split-log.

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

## Example of running with plain docker

```shell
docker run -e ACCESSKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -e SECRETKEY='asASfasfasdFasdf4qr22Fsdsdfwert4dssdfwf343fsdfsdghsSDGSDGdsg' -e NUMBER_OF_LINES='100000' -e FILENAME='a591844d24.2019-07-17.72.json.gz' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/' split-log
```

This downloads an object named test.json.gz from bucket `mybucket` in region `us-geo`, splits it into multiple files with each 100000 lines and compresses them with bzip2 and then uploads these to same region and bucket as object names `split/a591844d24.2019-07-17.72.xaaaaa.json.bz`, `split/.a591844d24.2019-07-17.72.xaaaab.json.bz` etc.

## Running with IBM Cloud Code Engine

You can run the split-log as a serverless job in IBM Cloud Code Engine. For that you need to build it as a docker image and push it to Docker Hub. If you don't want to build and push it yourself you can simply the published image in https://hub.docker.com/repository/docker/torsstei/split-log.

Make sure you have **ibmcloud** CLI installed. If not, refer [here](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli).

Make sure you have the [Code Engine plugin](https://cloud.ibm.com/codeengine/cli) installed for the CLI.

If you haven't used Code Engine in your account before log in configure the ibmcloud CLI as described [here](https://cloud.ibm.com/docs/codeengine?topic=codeengine-install-cli) and then create a project:
```
ibmcloud ce project create --name myproject --select
```

To see logs and status of your Code Engine jobs on the command line the ibmcloud CLI did also install the kubectl tool. Run the following:
```
ibmcloud ce project current
```
which shows you the environment variable KUBECONFIG that you must set to be able to use kubectl later.

Create a job definition for using the split-log docker image:
```
ibmcloud ce job create --name my-split-log-job --image docker.io/torsstei/split-log:latest -e ACCESSKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -e SECRETKEY='asASfasfasdFasdf4qr22Fsdsdfwert4dssdfwf343fsdfsdghsSDGSDGdsg' -e NUMBER_OF_LINES='100000' -e FILENAME='a591844d24.2019-07-17.72.json.gz' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/'
```

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
kubectl describe pod my-split-log-job-jobrun-prkks
```
At the end of the output you can see the pod execution events like this:
```
Events:
  Type    Reason     Age        From                  Message
  ----    ------     ----       ----                  -------
  Normal  Scheduled  <unknown>  default-scheduler     Successfully assigned 3307050b-2834/my-split-log-job-jobrun-prkks-0-0 to 10.240.0.78
  Normal  Pulling    2m23s      kubelet, 10.240.0.78  Pulling image "docker.io/torsstei/split-log:latest"
  Normal  Pulled     2m12s      kubelet, 10.240.0.78  Successfully pulled image "docker.io/torsstei/split-log:latest"
  Normal  Created    2m8s       kubelet, 10.240.0.78  Created container my-split-log-job
  Normal  Started    2m7s       kubelet, 10.240.0.78  Started container my-split-log-job
```
In that output you find the pod execution id (in this case `my-split-log-job-jobrun-prkks-0-0`).


Get the logs of the pod execution:
```
kubectl logs my-split-log-job-jobrun-prkks-0-0
```


