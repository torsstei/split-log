#!/bin/bash
x
if [ -z "$APIKEY" ]; then echo "Error: environment variable APIKEY is not set." && exit 1; fi
if [ -z "$FILENAME" ]; then echo "Error: environment variable FILENAME is not set." && exit 1; fi
if [ -z "$BUCKET" ]; then echo "Error: environment variable BUCKET is not set." && exit 1; fi
if [ -z "$REGION" ]; then echo "Error: environment variable REGION is not set." && exit 1; fi
if [[ $FILENAME != *.json.gz ]]; then echo "Error: FILENAME must be a valid .json.gz." && exit 1; fi

apikey=$APIKEY
inputfilename=`echo $FILENAME | rev | cut -c9- | rev`
bucket=$BUCKET
targetbucket=$bucket
region=$REGION
targetregion=$region
prefix=$PREFIX
targetprefix=$prefix
lines=100000
if [[ -v NUMBER_OF_LINES ]]; then lines=$NUMBER_OF_LINES; fi
if [[ -v TARGETPREFIX ]]; then targetprefix=$TARGETPREFIX; fi
if [[ -v TARGETBUCKET ]]; then targetbucket=$TARGETBUCKET; fi
if [[ -v TARGETREGION ]]; then targetregion=$TARGETREGION; fi
ibmcloud login -r us-south -apikey $apikey
rm -f $inputfilename.json.gz

echo Downloading cos://$region/$bucket/$prefix$inputfilename.json.gz ...
ibmcloud cos object-get --bucket $bucket --key $prefix$inputfilename.json.gz --region $region ./$inputfilename.json.gz

echo Splitting file $inputfilename.json.gz into files with $lines lines.
gunzip -c $inputfilename.json.gz | \
split -l $lines -a 10 --filter '\
	bzip2 > $FILE.bz2; \
	echo Uploading cos://'$targetregion'/'$targetbucket'/'$targetprefix$inputfilename'.$FILE.json.bz2 ...; \
	ibmcloud cos object-put --bucket '$targetbucket' --key '$targetprefix$inputfilename'.$FILE.json.bz2 --region '$targetregion' --body $FILE.bz2; \
	rm $FILE.bz2'
