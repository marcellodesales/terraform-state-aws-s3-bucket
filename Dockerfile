# https://github.com/aws/aws-cli/blob/v2/docker/Dockerfile
FROM amazon/aws-cli

RUN yum install jq -y

WORKDIR /app
COPY entrypoint.sh .
COPY aws-env.sh .
COPY create-dynamodb-lock-table.tf .
COPY terraform.tf .

VOLUME /root/.aws

ENTRYPOINT ["/app/entrypoint.sh"]
