#!/bin/bash

# specify parameters
VPC_NAME=$1 # VPC network name
REGION_NAME=$2 # Region name
NETWORK_TAG=$3 # NAT instance network tag
HEALTH_CHECK_NAME=$4 # Internal load balancer health check name
FW_HEALTH_CHECK_NAME=$5 # Firewall rule name for health check
PROJECT_NAME=$6 # Project ID

# create health check
gcloud compute health-checks create http "$HEALTH_CHECK_NAME" \
    --region="$REGION_NAME" \
    --port=80 \
    --project="$PROJECT_NAME"

# create firewall rule for load balancer health check
gcloud compute firewall-rules create "$FW_HEALTH_CHECK_NAME" \
	--network="$VPC_NAME" \
	--direction=INGRESS \
	--target-tags="$NETWORK_TAG" \
	--source-ranges=130.211.0.0/22,35.191.0.0/16 \
	--action=ALLOW \
	--rules=tcp,udp,icmp \
	--project="$PROJECT_NAME"
