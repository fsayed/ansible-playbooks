#!/bin/bash
echo -n `date`


function usage
{
    echo "Usage: $0 ipset_name inet_family app_type complex"
    echo 'ipset_name any short string without spaces'
    echo 'inet_family can be: inet (ipv4) or inet6 (ipv6)'
    echo 'app_type can be: epp'
    echo 'complex can be: au'
    exit 1
}

[[ $# -eq 0 ]] && usage

if [ -z "$1" ]
then
        echo 'failed: required parameter: ipset name'
        usage
        exit 203
else
        IPSET_PROD_NAME=$1
        IPSET_TEMP_NAME="${IPSET_PROD_NAME}_temp"
fi

case $2 in
    inet)
        FILE_DEST='/tmp/fttdumptestv4'
      	S3_BUCKET_FILE='fttdump_v4.csv'
        INET_FAMILY='inet'
        ;;
    inet6)
        FILE_DEST="/tmp/fttdumptestv6"
        S3_BUCKET_FILE='fttdump_v6.csv'
        INET_FAMILY='inet6'
        ;;
    *)
        echo 'failed: required parameter: ipv4|ipv6'
        usage
        exit 200
        ;;
esac

case $3 in
    epp)
        APP_TYPE='EPP'
        ;;
    *)
        echo 'failed: required parameter: application type epp'
        usage
        exit 201
        ;;
esac

case $4 in
    au)
        COMPLEX='AU'
        ;;
    *)
        echo 'failed: required parameter: complex au'
        usage
        exit 202
        ;;
esac

# Set AWS credentials and S3 paramters
AWS_KEY="AKIA5NUURUX65VHC4O54"
AWS_SECRET="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"
S3_BUCKET="fttdump"
S3_BUCKET_PATH="/"
S3_ACL="x-amz-acl:private"

#other vars
MAX_RETRY_COUNT=3
SLEEP_BETWEEN_RETRY=30

function s3download
{
  file=$1
  path=$2

  acl=${S3_ACL}
  bucket=${S3_BUCKET}
  bucket_path=${S3_BUCKET_PATH}

  date=$(date +"%a, %d %b %Y %T %z")
  content_type="application/octet-stream"
  sig_string="GET\n\n$content_type\n$date\n/$bucket$bucket_path$file"
  signature=$(echo -en "${sig_string}" | openssl sha1 -hmac "${AWS_SECRET}" -binary | base64)


  http_code=$(curl -D ${path}.headers -s -w "%{http_code}" -o ${path} \
    -H "Host: $bucket.s3.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "Authorization: AWS ${AWS_KEY}:$signature" \
     "https://${bucket}.s3.amazonaws.com${bucket_path}${file}")

  if [ $? -ne 0 ]
  then
      echo 'curl failure'
      return 1
  fi

  if [ $http_code -ne 200 ]
  then
      echo 'aws request failed'
      return 2
  fi

  header_md5sum=$(grep 'ETag: ' ${path}.headers | awk -F'"' '{print $2}')
  calc_md5sum=$(md5sum ${path} | awk '{print $1}')

  if [ "$header_md5sum" != "$calc_md5sum" ]
  then
	echo md5sum from http header does not match calculated md5sum
	echo possible incomplete download
	echo md5sum from http header $header_md5sum
	echo md5sum calculated for $path $calc_md5sum
	return 3
  fi

}


#MAIN

TRY_COUNTER=0
while [ $TRY_COUNTER -ne $MAX_RETRY_COUNT ]
do
	s3download $S3_BUCKET_FILE $FILE_DEST
	S3DOWNLOAD_RETURN_CODE=$?
	if [ $S3DOWNLOAD_RETURN_CODE -eq 0 ]
	  then
		break
 	  fi
        echo download function return code $S3DOWNLOAD_RETURN_CODE
	echo retrying download in $SLEEP_BETWEEN_RETRY seconds
	TRY_COUNTER=$((TRY_COUNTER+1))
	sleep $SLEEP_BETWEEN_RETRY
done

if [ $S3DOWNLOAD_RETURN_CODE -ne 0 ]
then
	echo "download failed with return code $S3DOWNLOAD_RETURN_CODE - exiting!"
	exit 100
fi

# make sure ipset sets (prod and temp) exists and create if it doesn't
/sbin/ipset -exist create $IPSET_PROD_NAME hash:net family $INET_FAMILY
if [ $? -ne 0 ]
then
	echo "failed to create $IPSET_PROD_NAME ipset"
	exit 101
fi

/sbin/ipset -exist create $IPSET_TEMP_NAME hash:net family $INET_FAMILY
if [ $? -ne 0 ]
then
	echo "failed to create $IPSET_TEMP_NAME ipset"
	exit 102
fi

# make sure the temp ipset is empty (flush)
/sbin/ipset flush $IPSET_TEMP_NAME
if [ $? -ne 0 ]
then
	echo "failed to flush $IPSET_TEMP_NAME ipset"
	exit 103
fi

# parse data file and load each ip/net into the temp ipset
for IPnet in $(grep "^${COMPLEX},${APP_TYPE},"  ${FILE_DEST}  | awk -F',' '{print $4}')
  do
    /sbin/ipset -exist add $IPSET_TEMP_NAME $IPnet
    if [ $? -ne 0 ]
      then
        echo "failed to not add $IPnet to $IPSET_TEMP_NAME ipset"
      fi
    done

# swap temp and prod ipsets
/sbin/ipset swap $IPSET_TEMP_NAME $IPSET_PROD_NAME
if [ $? -ne 0 ]
then
	echo "failed to swap ipsets $IPSET_TEMP_NAME to $IPSET_PROD_NAME"
	exit 104
fi

echo -n ' '`/sbin/ipset list $IPSET_PROD_NAME -terse | grep 'Number of entries'` ; echo -n ' md5sum: '`/sbin/ipset list $IPSET_PROD_NAME | grep -v 'Size in memory:' | sort | md5sum | awk '{print $1}'` ; echo
