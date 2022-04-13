#!/bin/bash

# specify parameters
PROJECT_NAME=$1 # Project ID
VPC_NAME=$2 # VPC network name
NETWORK_TAG=$3 # NAT instance network tag
REGION_NAME=$4 # Region name
NAT_INSTANCE_TEMPLATE_NAME=$5 # NAT instance template name

# create instance template
gcloud compute instance-templates create "$NAT_INSTANCE_TEMPLATE_NAME" \
  --project="$PROJECT_NAME" \
  --machine-type=f1-micro \
  --network-interface=address="",network-tier=PREMIUM,subnet="$VPC_NAME-subnet" \
  --can-ip-forward \
  --maintenance-policy=MIGRATE \
  --region="$REGION_NAME" \
  --tags="$NETWORK_TAG",http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name="$NAT_INSTANCE_TEMPLATE_NAME",image=projects/debian-cloud/global/images/debian-10-buster-v20220317,mode=rw,size=10,type=pd-balanced \
  --metadata startup-script='#! /bin/bash
  # Enable IP forwarding:
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/20-iptables.conf
  # iptables configuration
  iptables -t nat -F
  sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables-save
  # Use a web server to pass the health check for this example.
  # You should use a more complete test in production.
  apt-get update
  apt-get install apache2 tcpdump -y
  a2ensite default-ssl
  a2enmod ssl
  echo "Example web page to pass health check" | \
  tee /var/www/html/index.html \
  systemctl restart apache2'