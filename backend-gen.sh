#!/usr/bin/env bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

TABLE_NAME="terraform_state"
NAME="$(basename "$PWD")-$(date +%s)"
REGION="$(aws configure get region)"

while getopts "n:r:h" FLAG
do
	case "$FLAG" in
		n)
			NAME="$OPTARG"
		  ;;
		r)
			REGION="${OPTARG}"
		  ;;
    h)
      echo -e "-n\tUse S3 bucket custom name"
      echo -e "-r\tUse custom region"
      exit
      ;;
    *);;
	esac
done

# Check content of backend.tf
if ! [ -e "backend.tf" ] || [ -z "$(grep -w "bucket" backend.tf | xargs | cut -d ' ' -f3)" ]; then
  # Create S3 Bucket
  bucketstatus="$(aws s3api head-bucket --bucket "${NAME}" 3>&2 2>&1 1>&3-)"
  if echo "${bucketstatus}" | grep 'Not Found';
  then
    BUCKET="$(aws s3api create-bucket --bucket "${NAME}" --region "${REGION}" --output text)"
    echo "Bucket created s3:/$BUCKET"
  elif echo "${bucketstatus}" | grep 'Forbidden';
  then
    err "Bucket exists but not owned"
  elif echo "${bucketstatus}" | grep 'Bad Request';
  then
    err "Bucket name specified is less than 3 or greater than 63 characters"
  else
    echo "Bucket already exists"
  fi
else
  echo "Bucket already exists"
fi

# Write vackend.tf
cat << EOF > backend.tf
terraform {
  backend "s3" {
    bucket = "${NAME}"
    key    = "testkey"
    dynamodb_table = "${TABLE_NAME}"
    region = "${REGION}"
  }
}
EOF

# Check DynamoDB table
if aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null ; then
  err "Table already exists"
fi

# Create DynamoDB table
aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --table-class STANDARD 1>/dev/null
echo "Table created"
