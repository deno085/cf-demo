# cf-demo
Cloud Formation Demo

This demo deploys a load balanced ec2 environment in a new vpc. 

## Prerequisites
This demo makes use of a temporary S3 bucket to place cloud formation templates as well as a lambda function bundle, which must
exist before the script is run. If a hostname and domain is provided the hosted domain in route53 is required.

This script assumes the aws cli utility is installed and configured.

## Running the Demo
Usage: ./deploy.sh BUCKETNAME [HOSTNAME DOMAIN]
Example: ./deploy.sh devops-deploy-bucket demo domain.com

BUCKETNAME is the name of the build bucket to use during the deployment
HOSTNAME is the hostname for the application
DOMAIN is the hosted zone the host should be created in (domain name, ie example.com)

HOSTNAME and DOMAIN are not required.  If omitted, a DNS entry for the load balancer will not be created.

