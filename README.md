# hbr-pdl
Heart beat rate calculator written in python for docker to be deployed on AWS ECR and Lambda

Build, run container and test lambda locally
```
docker buildx build --platform linux/amd64 -f ./Dockerfile -t hbr-pdl:v12 .
docker rm -f hbr-pdl
docker run -d --name hbr-pdl -p 9000:8080 hbr-pdl:v12
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"age": "40"}' -o response.json
```

If this runs fine, then toy are ready to upload it ot AWS ESC
```
aws ecr create-repository --repository-name hbr-pdl --image-scanning-configuration scanOnPush=true
docker tag hbr-pdl <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl
aws ecr get-login-password | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl
```

Then create lambda function
```
aws lambda create-function --package-type Image --function-name hbr-pdl --role arn:aws:iam::474170254988:role/lambda-ex --code ImageUri=<aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl:v12
```
Here is how to lambda invoke
```
aws lambda invoke --function-name <lambda:arn> --cli-binary-format raw-in-base64-out --payload '{"age": "40"}' response.json
```
