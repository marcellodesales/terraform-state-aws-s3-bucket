#!/bin/bash

# Using the default profile if it's not provided
AWS_PROFILE=${AWS_PROFILE:-default}

export AWS_ACCESS_KEY_ID=$(aws configure get ${AWS_PROFILE}.aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get ${AWS_PROFILE}.aws_secret_access_key)
export AWS_SESSION_TOKEN=$(aws configure get ${AWS_PROFILE}.aws_session_token)
export AWS_REGION=$(aws configure list | grep region | awk '{print $2}')

echo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
echo AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
echo AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
echo AWS_REGION=$AWS_REGION
echo AWS_PROFILE=$AWS_PROFILE
