#!/bin/bash
set -eo pipefail

echo Running split-log for json.gz log archive into multiple json.gz...

if [ -z "$ACCESSKEY" ]; then echo "Error: environment variable ACCESSKEY is not set." && exit 1; fi
if [ -z "$SECRETKEY" ]; then echo "Error: environment variable SECRETKEY is not set." && exit 1; fi
if [ -z "$FILENAME" ]; then echo "Error: environment variable FILENAME is not set." && exit 1; fi
if [ -z "$BUCKET" ]; then echo "Error: environment variable BUCKET is not set." && exit 1; fi
if [ -z "$REGION" ]; then echo "Error: environment variable REGION is not set." && exit 1; fi
if [[ $FILENAME != *.json.gz ]]; then echo "Error: FILENAME must be a valid .json.gz." && exit 1; fi
if [ -n "$PRIVATE_ENDPOINTS" ]; then endpoint_prefix="direct."; echo "Using private COS endpoints"; fi

accesskey=$ACCESSKEY
secretkey=$SECRETKEY
targetaccesskey=$ACCESSKEY
targetsecretkey=$SECRETKEY
inputfilename=`echo $FILENAME | rev | cut -c9- | rev`
bucket=$BUCKET
targetbucket=$bucket
region=$REGION
if [ $region == 'us-geo' ]; then region='us'; fi
targetregion=$region
prefix=$PREFIX
targetprefix=$prefix
lines=100000
if [[ -v NUMBER_OF_LINES ]]; then lines=$NUMBER_OF_LINES; fi
if [[ -v TARGETPREFIX ]]; then targetprefix=$TARGETPREFIX; fi
if [[ -v TARGETBUCKET ]]; then targetbucket=$TARGETBUCKET; fi
if [[ -v TARGETREGION ]]; then targetregion=$TARGETREGION; fi
if [ $targetregion == 'us-geo' ]; then targetregion='us'; fi
if [[ -v TARGETACCESSKEY ]]; then targetaccesskey=$TARGETACCESSKEY; fi
if [[ -v TARGETSECRETKEY ]]; then targetsecretkey=$TARGETSECRETKEY; fi
inputendpoint='https://s3.'$endpoint_prefix$region'.cloud-object-storage.appdomain.cloud'
outputendpoint='https://s3.'$endpoint_prefix$targetregion'.cloud-object-storage.appdomain.cloud'

echo 'COS input endpoint is '$inputendpoint'. COS output endoint is '$outputendpoint'.'

mc config host add cos-input $inputendpoint $accesskey $secretkey
mc config host add cos-output $outputendpoint $targetaccesskey $targetsecretkey

echo Downloading cos://$region/$bucket/$prefix$inputfilename.json.gz, splitting it into files with $lines lines and uploading to cos://$targetregion/$targetbucket/$targetprefix

mc cat cos-input/$bucket/$prefix$inputfilename.json.gz | \
gunzip | \
split -l $lines -a 5 --filter '\
set -e; \
gzip | \
mc pipe cos-output/'$targetbucket'/'$targetprefix$inputfilename'.$FILE.json.gz; \
echo Uploaded cos://'$targetregion'/'$targetbucket'/'$targetprefix$inputfilename'.$FILE.json.gz'

echo 'Split successfully completed'

