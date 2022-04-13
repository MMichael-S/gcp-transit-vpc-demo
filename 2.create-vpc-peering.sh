#!/bin/bash

# specify parameters
PROJECT_NAME=$1 # Project ID
SRC_VPC_NAME=$2 # Peering source VPC name
DST_VPC_NAME=$3 # Peering target VPC name

# create vpc peering
gcloud compute networks peerings create "$SRC_VPC_NAME-to-$DST_VPC_NAME" \
    --network="$SRC_VPC_NAME" \
    --peer-project "$PROJECT_NAME" \
    --peer-network "$DST_VPC_NAME" \
    --import-custom-routes \
    --export-custom-routes \
    --import-subnet-routes-with-public-ip \
    --export-subnet-routes-with-public-ip