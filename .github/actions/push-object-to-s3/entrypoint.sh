#!/bin/bash

set -e

PROFILE_NAME="push-obj-s3"

# GitHub Actions will prefix env vars with INPUT_ and make them uppercase
aws configure set aws_access_key_id ${INPUT_AWS_ACCESS_KEY_ID} --profile ${PROFILE_NAME}
aws configure set aws_secret_access_key ${INPUT_AWS_SECRET_ACCESS_KEY} --profile ${PROFILE_NAME}
aws configure set region ${INPUT_AWS_REGION} --profile ${PROFILE_NAME}

aws s3 cp ${INPUT_SOURCE_FILE} s3://${INPUT_AWS_S3_BUCKET_NAME}${INPUT_DESTINATION_PATH}${INPUT_DESTINATION_FILE_NAME} --profile ${PROFILE_NAME}
