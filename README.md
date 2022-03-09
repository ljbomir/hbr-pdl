# hbr-pdl
Heart beat rate calculator written in python for docker to be deployed on AWS ECR and Lambda

#Build, run container and test lambda locally
docker buildx build --platform linux/amd64 -f ./Dockerfile -t hbr-pdl:v12 .
docker rm -f hbr-pdl
docker run -d --name hbr-pdl -p 9000:8080 hbr-pdl:v12
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"age": "40"}' -o response.json
