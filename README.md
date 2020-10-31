# Using env vars

* Execute the following to get the AWS env vars
  * https://unix.stackexchange.com/questions/272689/how-to-set-multiple-env-variables-from-stdout-pipe/272690#272690

```
source <(~/dev/github.com/marcellodesales/aws-s3-bucket-state/aws-env.sh | tail -n +2 | sed 's/ //g; s/^/export /')
```

# Setup Terraform data

```
$ docker-compose up --build
Building setup_s3_bucket
Step 1/6 : FROM amazon/aws-cli
 ---> c0f619671671
Step 2/6 : WORKDIR /app
 ---> Using cache
 ---> aa1ae8f9f5b7
Step 3/6 : COPY entrypoint.sh .
 ---> f0bc5f1763bf
Step 4/6 : COPY aws-env.sh .
 ---> b839ecb7147c
Step 5/6 : VOLUME /root/.aws
 ---> Running in af036f1decff
Removing intermediate container af036f1decff
 ---> be43cbe5641b
Step 6/6 : ENTRYPOINT ["/app/entrypoint.sh"]
 ---> Running in 78c3924d0d85
Removing intermediate container 78c3924d0d85
 ---> 9156f657ef1d

Successfully built 9156f657ef1d
Successfully tagged marcellodesales/terraform-setup-s3-bucket:latest
Recreating aws-s3-bucket-state_setup_s3_bucket_1 ... done
Attaching to aws-s3-bucket-state_setup_s3_bucket_1
setup_s3_bucket_1  |
setup_s3_bucket_1  | An error occurred (NoSuchBucket) when calling the ListObjectsV2 operation: The specified bucket does not exist
setup_s3_bucket_1  | make_bucket: super-cluster-state-dev
aws-s3-bucket-state_setup_s3_bucket_1 exited with code 0
```

# Delete Terraform Data S3 Bucket

```
$ docker-compose -f docker-compose-delete.yaml up --build
Building setup_s3_bucket
Step 1/6 : FROM amazon/aws-cli
 ---> c0f619671671
Step 2/6 : WORKDIR /app
 ---> Using cache
 ---> aa1ae8f9f5b7
Step 3/6 : COPY entrypoint.sh .
 ---> 0d434e5f5c12
Step 4/6 : COPY aws-env.sh .
 ---> 22b68bcdaca7
Step 5/6 : VOLUME /root/.aws
 ---> Running in 9629d1dd8732
Removing intermediate container 9629d1dd8732
 ---> cd4797573e85
Step 6/6 : ENTRYPOINT ["/app/entrypoint.sh"]
 ---> Running in fd61ab461a96
Removing intermediate container fd61ab461a96
 ---> 5e4ca8fe928a

Successfully built 5e4ca8fe928a
Successfully tagged marcellodesales/terraform-setup-s3-bucket:latest
Recreating aws-s3-bucket-state_setup_s3_bucket_1 ... done
Attaching to aws-s3-bucket-state_setup_s3_bucket_1
setup_s3_bucket_1  | remove_bucket: super-cluster-state-dev
aws-s3-bucket-state_setup_s3_bucket_1 exited with code 0
```
