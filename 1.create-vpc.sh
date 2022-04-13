#!/bin/bash

# specify parameters
PROJECT_NAME=$1 # Project ID
VPC_NAME=$2 # VPC network name
SUBNET_CIDR=$3 # VPC Subnet CIDR, eg, 10.1.0.0/16
TOPOLOGY_CIDR=$4 # Trust topology CIDR, eg, 10.0.0.0/8
REGION_NAME=$5 # Region name

# create vpc
gcloud compute networks create "$VPC_NAME" \
	--project="$PROJECT_NAME" \
	--subnet-mode=custom \
	--mtu=1460 \
	--bgp-routing-mode=regional

# create subnet
gcloud compute networks subnets create "$VPC_NAME-subnet" \
	--project="$PROJECT_NAME" \
	--range="$SUBNET_CIDR" \
	--network="$VPC_NAME" \
	--region="$REGION_NAME" \

# create firewall rules
gcloud compute firewall-rules create "$VPC_NAME-allow-custom" \
	--project="$PROJECT_NAME" \
	--network="projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
	--direction=INGRESS \
	--priority=65534 \
	--source-ranges="$SUBNET_CIDR" \
	--action=ALLOW \
	--rules=all

gcloud compute firewall-rules create "$VPC_NAME-allow-icmp" \
	--project="$PROJECT_NAME" \
	--network="projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
	--direction=INGRESS \
	--priority=65534 \
	--source-ranges=0.0.0.0/0 \
	--action=ALLOW \
	--rules=icmp

gcloud compute firewall-rules create "$VPC_NAME-allow-rdp" \
	--project="$PROJECT_NAME" \
	--network="projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
	--direction=INGRESS \
	--priority=65534 \
	--source-ranges=0.0.0.0/0 \
	--action=ALLOW \
	--rules=tcp:3389

gcloud compute firewall-rules create "$VPC_NAME-allow-ssh" \
	--project="$PROJECT_NAME" \
	--network="projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
	--direction=INGRESS \
	--priority=65534 \
	--source-ranges=0.0.0.0/0 \
	--action=ALLOW \
	--rules=tcp:22

gcloud compute firewall-rules create "$VPC_NAME-allow-all" \
	--project="$PROJECT_NAME" \
	--network="projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
	--direction=INGRESS \
	--priority=65534 \
	--source-ranges="$TOPOLOGY_CIDR" \
	--action=ALLOW \
	--rules=all