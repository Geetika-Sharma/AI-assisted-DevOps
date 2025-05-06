#!/bin/bash

#########################################################################
# Description: This script creates or deletes a VPC in AWS with the specified CIDR block.
# - Accepts two parameters: create or delete.
# - If 'create' is specified, it creates a VPC and a public subnet.
# - If 'delete' is specified, it deletes the VPC and its associated resources.
# - Throws an error if any other parameter is passed.
# - Creates a VPC with the specified CIDR block and Create a public subnet in the VPC if 'create' is specified.
# - Deletes the VPC and its associated resources if 'delete' is specified.
# - Verify if AWS CLI is installed. User could be using MAC or Linux or Windows.
# - Verify if the user has AWS CLI configured with the correct credentials.
###########################################################################

# variables
VPC_NAME="demo-vpc"
VPC_CIDR="10.0.0.0/16"
SUBNET_NAME="demo-subnet"
SUBNET_CIDR="10.0.3.0/24"
REGION="us-east-1"

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi
# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <create|delete>"
    exit 1
fi
# Check if the argument is either 'create' or 'delete'
if [ "$1" != "create" ] && [ "$1" != "delete" ]; then
    echo "Invalid argument. Use 'create' to create a VPC or 'delete' to delete a VPC."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install it and try again."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null
then
    echo "AWS CLI is not configured. Please configure it using 'aws configure' and try again."
    exit 1
fi

# Create or delete VPC based on the argument
if [ "$1" == "create" ]; then
    echo "Creating VPC..."
    # Create VPC and Subnet
    VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)
    if [ $? -ne 0 ]; then
        echo "Failed to create VPC. Please check your AWS credentials and permissions."
        exit 1
    fi
    echo "VPC created with ID: $VPC_ID"
    # Tag the VPC
    aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME --region $REGION
    if [ $? -ne 0 ]; then
        echo "Failed to tag VPC. Please check your AWS credentials and permissions."
        exit 1
    fi
    echo "VPC tagged with Name: $VPC_NAME"
    # Create Subnet
    SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --region $REGION --query 'Subnet.SubnetId' --output text)
    if [ $? -ne 0 ]; then
        echo "Failed to create Subnet. Please check your AWS credentials and permissions."
        exit 1
    fi
    echo "Subnet created with ID: $SUBNET_ID"
else
    echo "Deleting VPC..."
    # Delete Subnet
    aws ec2 delete-subnet --subnet-id $SUBNET_ID --region $REGION
    if [ $? -ne 0 ]; then
        echo "Failed to delete Subnet. Please check your AWS credentials and permissions."
        exit 1
    fi
    echo "Subnet deleted."
    # Delete VPC
    aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION
    if [ $? -ne 0 ]; then
        echo "Failed to delete VPC. Please check your AWS credentials and permissions."
        exit 1
    fi
    echo "VPC deleted."
fi