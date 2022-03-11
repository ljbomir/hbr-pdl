# HBR-PDL
### Introduction
HBR-PDL (**H**eart **B**eat **R**ate app built for **P**ython **D**ocker **L**ambda) is a small python application, which calculates the suitable heart beat rate limits based on given age.
There is a Docker file, which describes a minimum conifguration to build a docker image. Together with app.py they are placed in a separate folder /image.
So that running ```automated-deployment.sh``` script will:
1. Build all content in /image folder to a docker image
2. Create a repository on Amazon Elastic Container Registry
3. Push it to Amazon Elastic Container Service
4. Create AWS Lambda function
5. Perform a remote call against the Lambda function, which responds with a payload


Below you can see how to build and push a docker image to AWS ECR, ECS and Lambda.


### Versioning and user input

On the first run of the automated deployment script it will require user input and will create a new ```aws_cred.txt``` file having AWS credentials and built in counter. On the next run it will not require the user for the credentials anymore, but it will simply source them from the file. On each next run counter will be incremented and assigned as an image version. In this way every change to the files inside the docker image will be uploaded as a subsequent image version.

### Manual execution

 - Build, run container and test lambda locally
```
docker buildx build --platform linux/amd64 -f ./Dockerfile -t hbr-pdl:v12 .
docker rm -f hbr-pdl
docker run -d --name hbr-pdl -p 9000:8080 hbr-pdl:v12
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"age": "40"}' -o response.json
```

 - Upload it ot AWS ECR
```
aws ecr create-repository --repository-name hbr-pdl --image-scanning-configuration scanOnPush=true
docker tag hbr-pdl <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl
aws ecr get-login-password | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl
```

 - Create lambda function
```
aws lambda create-function --package-type Image --function-name hbr-pdl --role arn:aws:iam::474170254988:role/lambda-ex --code ImageUri=<aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hbr-pdl:v12
```
 - Invoke lambda and test the response
```
aws lambda invoke --function-name <lambda:arn> --cli-binary-format raw-in-base64-out --payload '{"age": "40"}' response.json
```
### Automated build

If you find this too complicated, just execute the automated procedure
```
./automated-deployment.sh
```
And it will do all of the above steps for you.
