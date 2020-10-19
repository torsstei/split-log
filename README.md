
# split-log Docker Image

## Parameters

 - ACCESSKEY: Your COS HMAC access key
 - SECRETKEY: Your COS HMAC secret access key
 - REGION: The region of your json.gz file on COS
 - BUCKET: The COS bucket name of your json.gz file
 - INPUTFILENAME: The name of your json.gz file on COS (when it is in a virtual folder you must specify it as PREFIX variable)
 - PREFIX: The optional prefix name of your json.gz file (optional, default is empty string)
 - LINES: The number of lines in each split file (optional, default is 100000)
 - TARGETREGION: The region of your target split files on COS (optional, default is same value as REGION)
 - TARGETBUCKET: The bucket of your target split files on COS (optional, default is same value as BUCKET)
 - TARGETPREFIX: The prefix of your target split files on COS (optional, default is same value as PREFIX)
 - TARGETACCESSKEY: Your COS HMAC access key for your target COS bucket (optional, default is same value as ACCESSKEY)
 - TARGETSECRETKEY: Your COS HMAC secret access key for your target COS bucket (optional, default is same value as SECRETKEY)

Run example:

```shell
docker run -e ACCESSKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -SECRETKEY='asASfasfasdFasdf4qr22Fsdsdfwert4dssdfwf343fsdfsdghsSDGSDGdsg' -e NUMBER_OF_LINES='100000' -e FILENAME='a591844d24.2019-07-17.72.json.gz' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/' split-log
```

This downloads an object named test.json.gz from bucket `mybucket` in region `us-geo`, splits it into multiple files with each 1000 lines and compresses them with bzip2 and then uploads these to same region and bucket as object names `split/a591844d24.2019-07-17.72.xaaaaa..json.bz`, `split/.a591844d24.2019-07-17.72.xaaaab.json.bz` etc.
