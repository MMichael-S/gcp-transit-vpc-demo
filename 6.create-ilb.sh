#!/bin/bash

# specify parameters
VPC_NAME=$1 # VPC network name
REGION_NAME=$2 # Region name
ILB_NAME=$3 # Internal load balancer name
HEALTH_CHECK_NAME=$4 # Internal load balancer health check name
PROJECT_NAME=$5 # Project ID

# create internal load balancer
gcloud compute backend-services create "$ILB_NAME" \
    --load-balancing-scheme=internal \
    --protocol=tcp \
    --region="$REGION_NAME" \
    --health-checks="$HEALTH_CHECK_NAME" \
    --health-checks-region="$REGION_NAME" \
    --project="$PROJECT_NAME"