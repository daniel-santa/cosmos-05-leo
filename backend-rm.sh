#!/usr/bin/env bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

# Check backend file
if ! [ -e "backend.tf" ]; then
    err "backend.tf not found"
fi

# User confirmation
read -r -p "Are you sure to destroy backend? [Y/n] " response
response=${response,,}
if ! [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
   exit
fi

# Read from backend.tf
BUCKET_NAME="$(grep -w "bucket" backend.tf | xargs | cut -d ' ' -f3)"
DYNAMO_TABLE="$(grep -w "dynamodb_table" backend.tf | xargs | cut -d ' ' -f3)"

# Check s3 bucket
bucketstatus="$(aws s3api head-bucket --bucket "${NAME}" 3>&2 2>&1 1>&3-)"
if echo "${bucketstatus}" | grep 'Not Found';
    err "Bucket not found"
then
    echo
elif echo "${bucketstatus}" | grep 'Forbidden';
then
    err "Bucket exists but not owned"
fi
# Delete S3 Bucket
aws s3api delete-bucket --bucket "${BUCKET_NAME}"

# Check DynamoDB table
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null ; then
  err "Table does not exist"
fi

# Delete DynamoDB table
aws dynamodb delete-table --table-name "${DYNAMO_TABLE}" 1>/dev/null

rm "$PWD/"backend.tf