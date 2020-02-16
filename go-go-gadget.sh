#!/bin/bash

mkdir -p ~/.aws/
echo "[default]" >> ~/.aws/credentials
echo "aws_access_key_id = $S3_BUCKET_KEY" >> ~/.aws/credentials
echo "aws_secret_access_key = $S3_BUCKET_SECRET" >> ~/.aws/credentials

echo "[default]" >> ~/.aws/config
echo "region = $AWS_REGION" >> ~/.aws/config

aws s3 mv /tmp/domains.txt s3://$S3_BUCKET_NAME/tmp/$UUID

for word in $(cat /tmp/domains.txt);
do
  echo "http://$word" >> /tmp/full-domains.txt
  echo "https://$word" >> /tmp/full-domains.txt
done

takeover -T 3 -t 20 -l /tmp/full-domains.txt -o takeover.json

python3 process.py

echo '{"task_type":"slack","body":"takeover complete"}' > /tmp/$UUID
aws sqs send-message --queue-url $SQS_URL --message-body $(cat /tmp/$UUID)
