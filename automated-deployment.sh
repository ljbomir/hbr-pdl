#!/bin/bash
if [ -f "aws_cred.txt" ] && [ $(echo "aws_cred.txt"|wc -l)==6 ] &&  grep -q count aws_cred.txt 
then
	perl -pi -e 's/(count=)(\d+)/$1.($2+1)/ge' aws_cred.txt 
else
	read -rp "Please enter aws_account_id:" aws_account_id
	echo "aws_account_id=\"$aws_account_id\"" >> aws_cred.txt
	read -rp "Please enter default AWS region:" defRegion
	echo "defRegion=\"$defRegion\"" >> aws_cred.txt
	read -rp "Please enter access key:" accKey
	echo "accKey=\"$accKey\"" >> aws_cred.txt
	read -rp "Please enter access key secret:" secAccKey
	echo "secAccKey=\"$secAccKey\"" >> aws_cred.txt
	read -rp "Please enter docker container name. This will also be used as Lambda function and repository names:" dockerName
	echo "dockerName=\"$dockerName\"" >> aws_cred.txt
	echo "count=1" >> aws_cred.txt
	
fi


source aws_cred.txt
aws configure set aws_access_key_id "$accKey"
aws configure set aws_secret_access_key "$secAccKey"
aws configure set default.region "$defRegion"

docker buildx build --platform linux/amd64 -f image/Dockerfile -t "$dockerName:v$count" image/
aws ecr create-repository --repository-name "$dockerName" --image-scanning-configuration scanOnPush=true 2>/dev/null
docker tag "$dockerName:v$count" "$aws_account_id.dkr.ecr.$defRegion.amazonaws.com/$dockerName:v$count"
aws ecr get-login-password | docker login --username AWS --password-stdin "$aws_account_id.dkr.ecr.$defRegion.amazonaws.com"
docker push "$aws_account_id.dkr.ecr.$defRegion.amazonaws.com/$dockerName:v$count"

aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' 2>/dev/null
aws lambda create-function --package-type Image --function-name "${dockerName}"_v"${count}" --role "arn:aws:iam::$aws_account_id:role/lambda-ex" --code ImageUri="$aws_account_id.dkr.ecr.$defRegion.amazonaws.com/$dockerName:v$count"
sleep 45
aws lambda invoke --function-name "${dockerName}_v${count}" --cli-binary-format raw-in-base64-out --payload '{"age": "40"}' response.json; cat response.json
