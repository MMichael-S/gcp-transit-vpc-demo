#!/bin/bash

# specify parameters
VPC_NAME=$1 # VPC network name
ILB_FRONT_IP_ADDRESS=$2 # Internal load balance frontend ip address
TOPOLOGY_CIDR=$3 # Trust topology CIDR, eg, 10.0.0.0/8
PROJECT_NAME=$4 # Project ID
NEXT_HOP_ILB_ROUTE_NAME="$VPC_NAME-next-hop-ilb-route"
NEXT_HOP_ILB_NETWORK_TAG="$VPC_NAME-next-hop-ilb"

# create spoke route via ilb in transit vpc
gcloud compute routes create "$NEXT_HOP_ILB_ROUTE_NAME" \
    --network="$VPC_NAME" \
    --destination-range="$TOPOLOGY_CIDR" \
    --next-hop-ilb="$ILB_FRONT_IP_ADDRESS" \
    --tags="$NEXT_HOP_ILB_NETWORK_TAG" \
    --priority 800 \
    --project="$PROJECT_NAME"