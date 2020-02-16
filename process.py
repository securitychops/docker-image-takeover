#!/usr/bin/env python3

import boto3
import json

with open('takeover.json') as json_file:
    data = json.load(json_file)

cleaned_up = []
for domain in data["domains"]:
    clean_domain = domain.lower().replace("https://","").replace("http://","").replace("\\","")
    clean_service = data["domains"][domain]["service"].replace("\\","")
    clean_error = data["domains"][domain]["error"].replace("\\","")

    tmp_clean = f"{clean_domain}|{clean_service}|{clean_error}"

    if tmp_clean not in cleaned_up:
        cleaned_up.append(tmp_clean)

sqs = boto3.resource('sqs')
queue = sqs.get_queue_by_name(QueueName='pipeline')

for item in cleaned_up:

    split = item.split("|")

    tmp_takeover = f"possible subdomain takeover : {split[0]} : {split[1]} : {split[2]}"

    body = '{"task_type":"slack","body":"'+tmp_takeover+'"}'

    print(body)

    queue.send_message(MessageBody=body)
