# Kasm Multi-Server Deployment on AWS using Terraform

This guide provides step-by-step instructions for setting up a Kasm multi-server environment on AWS using Terraform. The setup includes creating the necessary infrastructure, generating SSH keys, and configuring Kasm Workspaces.

## Prerequisites

1. **AWS Account**: Ensure you have an active AWS account.
2. **Terraform**: Install Terraform on your local machine.
3. **SSH Key Pair**: Generate an SSH key pair if you don't have one:

   ```sh
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

## Directory Structure

Create a directory to store your Terraform configuration files:

```
kasm-multi-server/
|-- main.tf
|-- keys.tf
|-- variables.tf
|-- secrets.tfvars
```

## Terraform Configuration Overview

### `main.tf`

This file defines the main configuration for setting up the AWS infrastructure:

1. **Provider Configuration**: Specifies the AWS region and credentials.
2. **VPC and Subnets**: Creates a Virtual Private Cloud (VPC) and multiple subnets for different components (webapp, database, agent, CPX, Windows).
3. **Security Groups**: Defines security groups with appropriate rules for webapp, database, agent, and CPX servers.
4. **EC2 Instances**: Launches EC2 instances for webapp servers, database, agents, and CPX.
5. **Internet and NAT Gateways**: Sets up gateways to allow internet access.
6. **Load Balancer**: Configures an Application Load Balancer (ALB) to distribute traffic to the webapp instances.

### `keys.tf`

This file handles the SSH key pair:

1. **Variable for Public Key Path**: Specifies the path to your public SSH key.
2. **AWS Key Pair Resource**: Creates an AWS key pair using your public key.

### `variables.tf`

This file defines the variables used in the configuration:

1. **AWS Credentials**: Variables for AWS access key and secret key.
2. **SSH Key Path**: Variable for the path to your public SSH key.

### `secrets.tfvars`

This file stores sensitive information like AWS credentials:

1. **AWS Access Key**: Your AWS access key.
2. **AWS Secret Key**: Your AWS secret key.

## Steps to Initialize and Apply Terraform

### 1. Initialize Terraform

Run the following command to initialize the Terraform configuration:

```sh
terraform init
```

### 2. Plan Terraform Deployment

Generate an execution plan to preview the changes Terraform will make to your infrastructure:

```sh
terraform plan -var-file="secrets.tfvars"
```

### 3. Apply Terraform Deployment

Apply the Terraform configuration to create the infrastructure:

```sh
terraform apply -var-file="secrets.tfvars"
```

## Post-Deployment Configuration

### 1. Set Up Kasm Servers

SSH into each server using the private key and install Kasm Workspaces:

```sh
ssh -i ~/.ssh/id_rsa ubuntu@your_server_ip
```

Follow the [Kasm Workspaces installation guide](https://www.kasmweb.com/docs/latest/installation.html) to complete the setup.

### 2. Configure Load Balancer

Ensure that your load balancer is routing traffic correctly to the Kasm servers. Point your domain `kasm.nighthawkcodingsociety.com` to the load balancer's DNS name.

## Conclusion

You have successfully set up a Kasm multi-server environment on AWS using Terraform. This setup includes SSH access to the servers and an Application Load Balancer to distribute traffic. Adjust the configuration files as needed for your specific requirements.

For any issues or further customization, refer to the official Terraform and AWS documentation.