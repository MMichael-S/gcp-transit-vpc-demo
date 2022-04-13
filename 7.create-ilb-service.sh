#!/bin/bash

# specify parameters
VPC_NAME=$1 # VPC network name
REGION_NAME=$2 # Region name
ILB_NAME=$3 # Internal load balancer name
NAT_INSTANCE_GROUP_NAME=$4 # NAT instance group name
ILB_FRONT_IP_ADDRESS=$5 # Internal load balance frontend ip address
PROJECT_NAME=$6 # Project ID
ILB_FORWARDING_RULE_NAME="$ILB_NAME-fr"

# create ilb backend service
gcloud compute backend-services add-backend "$ILB_NAME" \
    --region="$REGION_NAME" \
    --instance-group="$NAT_INSTANCE_GROUP_NAME" \
    --instance-group-region="$REGION_NAME" \
    --project="$PROJECT_NAME"

# create ilb frontend service
gcloud compute forwarding-rules create "$ILB_FORWARDING_RULE_NAME" \
    --region="$REGION_NAME" \
    --load-balancing-scheme=internal \
    --network="$VPC_NAME" \
    --subnet="$VPC_NAME-subnet" \
    --ip-protocol=TCP \
    --address="$ILB_FRONT_IP_ADDRESS" \
    --ports=ALL \
    --allow-global-access \
    --backend-service="$ILB_NAME" \
    --backend-service-region="$REGION_NAME" \
    --project="$PROJECT_NAME"
