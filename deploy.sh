#!/usr/bin/env bash

if [ $# -lt 1 ];
then
    echo "Usage: $0 BUCKETNAME [HOSTNAME DOMAIN]"
    echo "Example: ./deploy.sh devops-deploy-bucket demo domain.com"
    echo ""
    echo "BUCKETNAME is the name of the build bucket to use during the deployment"
    echo "HOSTNAME is the hostname for the application"
    echo "DOMAIN is the hosted zone the host should be created in (domain name, ie example.com)"
    echo ""
    echo "This script assumes the aws cli utility is installed and configured"
    exit 1
fi

if [ $# -gt 2 ];
then
    hostname=$2
    domainname=$3
else
    hostname=""
    domainname=""
fi

echo "Build bucket: ${1}"

aws s3 cp ./amilookup.json "s3://${1}/amilookup.json"
aws s3 cp ./amilookup.zip "s3://${1}/amilookup.zip"
aws s3 cp ./vpc.json "s3://${1}/vpc.json"

echo "Creating ssh key"
if [ -f app-demo.pem ]; then
    rm app-demo.pem
fi
aws ec2 create-key-pair --key-name app-demo >app-demo.json

jsonAppParameters="[
    {\"ParameterKey\":\"BuildBucket\", \"ParameterValue\":\"${1}\"},
    {\"ParameterKey\":\"HostName\", \"ParameterValue\":\"${hostname}\"},
    {\"ParameterKey\":\"HostDomain\", \"ParameterValue\":\"${domainname}\"},
    {\"ParameterKey\":\"KeyName\", \"ParameterValue\":\"app-demo\"}
]"

echo $jsonAppParameters >"params.json"

aws cloudformation create-stack --stack-name "app-demo" --template-body "file://basic.json" --capabilities CAPABILITY_IAM --parameters "file://params.json"

echo "Stack Deploying"

appstackstate=$(aws cloudformation describe-stacks --stack-name="app-demo" --output text | grep STACKS | cut -f7)
sleep 5

while [ $appstackstate = "CREATE_IN_PROGRESS" ]; do
   sleep 10
   appstackstate=$(aws cloudformation describe-stacks --stack-name="app-demo" --output text | grep STACKS | cut -f7)
   echo "Stack State: $appstackstate"
done

if [ $appstackstate = "CREATE_COMPLETE" ]; then
    aws s3 rm "s3://${1}/amilookup.json"
    aws s3 rm "s3://${1}/amilookup.zip"
    aws s3 rm "s3://${1}/vpc.json"
    if [ $# -gt 2 ];
    then
        echo "Checking http://${2}.${3}/"
        curl -sSf "http://${2}.${3}/" >/dev/null
    fi
    exit 0
else
    exit 1
fi
