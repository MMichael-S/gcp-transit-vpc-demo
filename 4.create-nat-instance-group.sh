#!/bin/bash

# specify parameters
PROJECT_NAME=$1 # Project ID
VPC_NAME=$2 # VPC network name
REGION_NAME=$3 # Region name
NAT_INSTANCE_GROUP_NAME=$4 # NAT instance group name
NAT_INSTANCE_TEMPLATE_NAME=$5 # NAT instance template name

# create managed instance group
gcloud beta compute instance-groups managed create "$NAT_INSTANCE_GROUP_NAME" \
  --project="$PROJECT_NAME" \
  --base-instance-name="$VPC_NAME-nat-instance" \
  --size=2 \
  --template="$NAT_INSTANCE_TEMPLATE_NAME" \
  --zones="$REGION_NAME-a","$REGION_NAME-b" \
  --target-distribution-shape=EVEN \
  --instance-redistribution-type=NONE