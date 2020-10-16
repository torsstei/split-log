
# split-log Docker Image

## Parameters

 - APIKEY: Your IAM APIKEY
 - REGION: The region of your json.gz file on COS
 - BUCKET: The COS bucket name of your json.gz file
 - INPUTFILENAME: The name of your json.gz file on COS (when it is in a virtual folder you must specify it as PREFIX variable)
 - PREFIX: The optional prefix name of your json.gz file (optional, default is empty string)
 - LINES: The number of lines in each split file (optional, default is 1000)
 - TARGETREGION: The region of your target split files on COS (optional, default is value iof REGION)
 - TARGETBUCKET: The bucket of your target split files on COS (optional, default is value iof BUCKET)
 - TARGETPREFIX: The prefix of your target split files on COS (optional, default is value iof PREFIX)

Run example:

```shell
docker run -e APIKEY='YNiasfuasdfufWWfsdWDFoOIIOUFEgpQ7qVVTkDSD4De' -e NUMBER_OF_LINES='1000' -e FILENAME='test' -e BUCKET='results' -e REGION='us-geo' -e TARGETPREFIX='split/' split-log
```

This downloads an object named test.json.gz from bucket `mybucket` in region `us-geo`, splits it into multiple files with each 1000 lines and compresses them with bzip2 and then uploads these to same region and bucket as object names `split/test.split00000.json.bz`, `split/test.split00001.json.bz` etc.
