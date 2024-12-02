# Terraform Setup Guide

## Prerequisites

1.**Install AWS CLI** and configure it using the following command:

   ```bash
   aws configure
   ```

**Set up AWS:**

- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-east-1`)
- Default output format (e.g., `json`)

2.**Install Terraform**:

- Download Terraform from the [official website](https://www.terraform.io/downloads).
- Ensure that Terraform is in your system's PATH.

## Step 1: Set Up AWS CLI Profile

If you have multiple profiles, specify the AWS profile to use by exporting it before running Terraform commands:

```bash
export AWS_PROFILE=<profile_name>
```

Replace `<profile_name>` with your desired AWS CLI profile name.

## Step 2: Clone the Repository

Clone the repository containing your Terraform configuration files:

```bash
git clone <git@github.com:Sanjay-Cloud-Computing/tf-aws-infra.git>
```

Navigate to the cloned directory:

```bash
cd <tf-ws-infra.git>
```

## Step 3: Create or Update `terraform.tfvars`

Create a file named `terraform.tfvars` in the root of your project directory, and add the following values:

```hcl
region                 = "us-east-1"
vpc_cidr_base          = "10.0.0.0/16"
no_of_vpcs             = "1"
max_availability_zones = "2"
public_subnet_per_vpc  = "1"
private_subnet_per_vpc = "1"
vpc_name               = "MyVpc"
custom_ami_id          = "ami-09caa919c5a7284ef"
application_port       = "5000"
instance_type          = "t2.micro"
key_name               = "Sanjay-Mac"
db_password            = "<enter-password>"

```

## Step 4: Initialize Terraform

Run the following command to initialize the Terraform configuration directory:

```bash
terraform init
```

## Step 5: Plan the Infrastructure

Generate an execution plan to review what resources will be created:

```bash
terraform plan
```

## Step 6: Create the VPC and Associated Resources

To create the VPC and its associated resources, run the following command:

```bash
terraform apply
```

Type `yes` when prompted to confirm and start the resource creation.

## Step 7: Verify the Deployment

After the Terraform apply completes, you can log in to your [AWS Management Console](https://aws.amazon.com/console/) and navigate to the **VPC Dashboard**.

## Step 8: Destroy the Infrastructure

To delete the resources and avoid unnecessary charges, run:

```bash
terraform destroy -var-file="terraform.tfvars"
```

Type `yes` to confirm and start the deletion process

3.**Import Certificate using awscli**

sudo aws acm import-certificate \
    --certificate fileb:///Users/sanjay/Documents/Cloud/a09/demo_cloudsan_me/demo_cloudsan_me.crt \
    --certificate-chain fileb:///Users/sanjay/Documents/Cloud/a09/demo_cloudsan_me/demo_cloudsan_me.ca-bundle \
    --private-key fileb:///Users/sanjay/Documents/Cloud/a09/private.key \
    --profile demo
