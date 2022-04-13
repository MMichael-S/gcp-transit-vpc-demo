#!/bin/bash

# specify parameters
PROJECT_NAME="ryanlao-67"
TOPOLOGY_CIDR="10.0.0.0/8"

TRANSIT_1_VPC_NAME="demo-transit-1-vpc"
TRANSIT_1_VPC_CIDR="10.1.0.0/16"
TRANSIT_1_VPC_REGION="asia-southeast1"

SPOKE_1_VPC_NAME="demo-spoke-1-vpc"
SPOKE_1_VPC_CIDR="10.11.0.0/16"
SPOKE_1_VPC_REGION="asia-east1"

SPOKE_2_VPC_NAME="demo-spoke-2-vpc"
SPOKE_2_VPC_CIDR="10.12.0.0/16"
SPOKE_2_VPC_REGION="asia-east2"

NAT_INSTANCE_TAG="nat-instance"
NAT_INSTANCE_TEMPLATE_NAME="$TRANSIT_1_VPC_NAME-nat-instance-template"
NAT_INSTANCE_GROUP_NAME="$TRANSIT_1_VPC_NAME-nat-instance-group"

TRANSIT_ILB_NAME="$TRANSIT_1_VPC_NAME-transit-ilb"
TRANSIT_ILB_HEALTH_CHECK_FW="$TRANSIT_ILB_NAME-allow-health-check"
TRANSIT_ILB_HEALTH_CHECK_NAME="$TRANSIT_ILB_NAME-health-check"
TRANSIT_ILB_IP_ADDRESS="10.1.0.100"

# step 1
# create transit vpc, spoke 1 vpc, spoke 2 vpc
# parameters: project-id, vpc-name, subnet-cidr, trust-cidr, region-name
./1.create-vpc.sh "$PROJECT_NAME" "$TRANSIT_1_VPC_NAME" "$TRANSIT_1_VPC_CIDR" "$TOPOLOGY_CIDR" "$TRANSIT_1_VPC_REGION"
./1.create-vpc.sh "$PROJECT_NAME" "$SPOKE_1_VPC_NAME" "$SPOKE_1_VPC_CIDR" "$TOPOLOGY_CIDR" "$SPOKE_1_VPC_REGION"
./1.create-vpc.sh "$PROJECT_NAME" "$SPOKE_2_VPC_NAME" "$SPOKE_2_VPC_CIDR" "$TOPOLOGY_CIDR" "$SPOKE_2_VPC_REGION"

# step 2
# create vpc peering
# parameters: project-id, source-vpc-name destination-vpc-name
./2.create-vpc-peering.sh "$PROJECT_NAME" "$TRANSIT_1_VPC_NAME" "$SPOKE_1_VPC_NAME"
./2.create-vpc-peering.sh "$PROJECT_NAME" "$TRANSIT_1_VPC_NAME" "$SPOKE_2_VPC_NAME"
./2.create-vpc-peering.sh "$PROJECT_NAME" "$SPOKE_1_VPC_NAME" "$TRANSIT_1_VPC_NAME"
./2.create-vpc-peering.sh "$PROJECT_NAME" "$SPOKE_2_VPC_NAME" "$TRANSIT_1_VPC_NAME"

# step 3
# create nat instance template in transit vpc
# parameters: project-id, vpc-name, network-tag, region-name, nat-instance-template-name
./3.create-nat-instance-template.sh "$PROJECT_NAME" "$TRANSIT_1_VPC_NAME" "$NAT_INSTANCE_TAG" "$TRANSIT_1_VPC_REGION" \
  "$NAT_INSTANCE_TEMPLATE_NAME"

# step 4
# create nat instance via managed instance group
# parameters: project-id, vpc-name, region-name, nat-instance-group-name, nat-instance-template-name
./4.create-nat-instance-group.sh "$PROJECT_NAME" "$TRANSIT_1_VPC_NAME" "$TRANSIT_1_VPC_REGION" \
  "$NAT_INSTANCE_GROUP_NAME" "$NAT_INSTANCE_TEMPLATE_NAME"

# step 5
# create internal load balancer health check
# parameters: vpc-name, region-name, network-tag, ilb-health-check-name, fw-name, project-id
./5.create-ilb-health-check.sh "$TRANSIT_1_VPC_NAME" "$TRANSIT_1_VPC_REGION" "$NAT_INSTANCE_TAG" \
  "$TRANSIT_ILB_HEALTH_CHECK_NAME" "$TRANSIT_ILB_HEALTH_CHECK_FW" "$PROJECT_NAME"

# step 6
# create internal load balancer in transit vpc
# parameters: vpc-name, region-name, ilb-name, ilb-health-check-name, project-id
./6.create-ilb.sh "$TRANSIT_1_VPC_NAME" "$TRANSIT_1_VPC_REGION" "$TRANSIT_ILB_NAME" "$TRANSIT_ILB_HEALTH_CHECK_NAME" \
  "$PROJECT_NAME"

# step 7
# create internal load balancer backend service
# parameters: vpc-name, region-name, ilb-name, nat-instance-group-name, ilb-ip-address, project-id
./7.create-ilb-service.sh "$TRANSIT_1_VPC_NAME" "$TRANSIT_1_VPC_REGION" "$TRANSIT_ILB_NAME" \
  "$NAT_INSTANCE_GROUP_NAME" "$TRANSIT_ILB_IP_ADDRESS" "$PROJECT_NAME"

# step 8
# create route from spoke vpc to transit vpc
# parameters: vpc-name, ilb-frontend-ip, trust-cidr, project-id
./8.create-spoke-nexthop-ilb-route.sh "$SPOKE_1_VPC_NAME" "$TRANSIT_ILB_IP_ADDRESS" "$TOPOLOGY_CIDR" "$PROJECT_NAME"
./8.create-spoke-nexthop-ilb-route.sh "$SPOKE_2_VPC_NAME" "$TRANSIT_ILB_IP_ADDRESS" "$TOPOLOGY_CIDR" "$PROJECT_NAME"
