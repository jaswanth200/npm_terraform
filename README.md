# AWS Infrastructure with Terraform

This project provisions an AWS infrastructure using Terraform and deploys a React application using Jenkins. The infrastructure includes a VPC, subnets, security groups, an internet gateway, and EC2 instances. The Jenkins pipeline is used to automate the provisioning and deployment processes.

## Table of Contents

* [Project Structure](#project-structure)
* [Prerequisites](#prerequisites)
* [Setup Instructions](#setup-instructions)
* [Terraform Commands](#terraform-commands)
* [Jenkins Pipeline](#jenkins-pipeline)
* [Outputs](#outputs)

Project Structure
=================
```
├── fold1/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── Jenkinsfile1
└── Jenkinsfile2
```

* fold1/main.tf: Contains the Terraform configuration for AWS resources.
* fold1/outputs.tf: Defines the outputs of the Terraform configuration.
* Jenkinsfile1: Jenkins pipeline for initializing and applying Terraform configuration.
* Jenkinsfile2: Jenkins pipeline for deploying the React application.

  Prerequisites
  =============
* Terraform (>= 1.0.0)
* AWS account with necessary IAM permissions
* Jenkins
* SSH access to a remote VM for deployment
  
Setup Instructions
==================
# <h3>AWS Setup with Terraform</h3>

# <h3>1. Navigate to the Terraform directory:</h3>
```
cd file1
```
# <h3>2. Initialize Terraform:</h3>
```
terraform init -upgrade
```
# <h3>3. Apply the Terraform configuration:</h3>
```
terraform apply -auto-approve
```
**<h3>4.** Note: Ensure the hhkey SSH key pair exists in your AWS account or modify the main.tf file to use an existing key.</h3>

# <h2>Jenkins Setup</h2>
**1.** Create a Jenkins job for each pipeline using Jenkinsfile1 and Jenkinsfile2.<br>
**2.** Configure the job:
* For Jenkinsfile1, ensure it points to the correct Terraform directory (fold1).
* For Jenkinsfile2, replace placeholders (${remote_vm_ip_address}, ${nexus_ip_address}, ${img_tag}) with actual values.
**3.** Run the Jenkins jobs sequentially:
* Start with the job using Jenkinsfile1 to provision AWS resources.
* Then run the job using Jenkinsfile2 to deploy the React application.

Terraform Commands
==================
* Initialize Terraform:
```
terraform init -upgrade
```
* Validate the configuration:
```
terraform validate
```
* Apply the configuration:
```
terraform apply -auto-approve
```
* Destroy the infrastructure:
```
terraform destroy -auto-approve
```

Jenkins Pipeline
================
<b><h3>Jenkinsfile1</h3></b>
This pipeline performs the following stages:<br>
**1.** <b>Terraform Init:</b> Initializes the Terraform configuration.<br>
**2.** <b>Terraform Apply:</b> Applies the Terraform configuration to provision AWS resources.
<b><h3>Jenkinsfile2</h3></b>
This pipeline performs the following stages:<br>
**1.** <b>Getting tar file from Nexus:</b> Downloads a tar file from the Nexus repository.<br>
**2.** <b>Unarchive the tar file:</b> Unarchives the tar file on the remote VM.<br>
**3.** <b>Run the REACT APPLICATION:</b> Runs the React application using the specified Build file.

Outputs
=======
After applying the Terraform configuration, the following outputs will be available:

* <b>react_first_instance_ami:</b> AMI ID of the React application instance.
* <b>react_first_instance_ip:</b> Public IP of the React application instance.
* <b>provpc:</b> VPC ID.
* <b>proig:</b> Internet Gateway ID.
* <b>aval_1a_subnet:</b> Subnet ID for availability zone ap-south-1a.
* <b>aval_1b_subnet:</b> Subnet ID for availability zone ap-south-1b.
* <b>aval_1c_subnet:</b> Subnet ID for availability zone ap-south-1c.
* <b>prosg:</b> Security Group ID.


# AWS Autoscaling and Load Balancing with Terraform

This project extends the AWS infrastructure setup by adding an Application Load Balancer (ALB) and an Auto Scaling Group (ASG) to the existing VPC created in the previous Terraform configuration. The Jenkins pipeline is used to automate the provisioning process.

## Table of Contents

* [Project Structure](#project-structure)
* [Prerequisites](#prerequisites)
* [Setup Instructions](#setup-instructions)
* [Terraform Commands](#terraform-commands)
* [Jenkins Pipeline](#jenkins-pipeline)
* [Variables](#variables)
* [Outputs](#outputs)

## Project Structure
```
├── fold2/
│ ├── main.tf
│ ├── variables.tf
├── Jenkinsfile
```

* **fold2/main.tf**: Contains the Terraform configuration for load balancer, auto-scaling, and security groups.
* **fold2/variables.tf**: Defines variables used in the Terraform configuration.
* **Jenkinsfile**: Jenkins pipeline for initializing and applying the Terraform configuration.

## Prerequisites

* Terraform (>= 1.0.0)
* AWS account with necessary IAM permissions
* Jenkins
* Existing VPC and networking setup from `fold1`

## Setup Instructions

### AWS Setup with Terraform

1. **Ensure you have the Terraform state file from the previous configuration (`fold1`):**
   - It should be located at `/var/lib/jenkins/workspace/npm_Terraform_VM_Create/file1/terraform.tfstate`.

2. **Navigate to the Terraform directory:**
   ```sh
   cd fold2
* Initialize Terraform:
```
terraform init -upgrade
```
* Apply the Terraform configuration:
```
terraform apply -auto-approve
```
# Jenkins Setup
**1.** Create a Jenkins job using the Jenkinsfile located in fold2/.<br>
**2.** Configure the job:<br>
**3.** Ensure it points to the correct Terraform directory (fold2).<br>
**4.** Run the Jenkins job to provision the load balancer and auto-scaling group on AWS.

Terraform Commands
==================
* Initialize Terraform:
```
terraform init -upgrade
```
* Validate the configuration:
```
terraform validate
```
* Apply the configuration:
```
terraform apply -auto-approve
```
* Destroy the infrastructure:
```
terraform destroy -auto-approve
```

# Jenkins Pipeline
The Jenkins pipeline in fold2 (Jenkinsfile) performs the following stages:<br>

**1.** <b>Terraform Init:</b> Initializes the Terraform configuration.<br>
**2.** <b>Terraform Apply:</b> Applies the Terraform configuration to provision the load balancer and auto-scaling group.

# Variables
The following variables are defined in file2/variables.tf:<br>

* <b>asgmin:</b> Minimum size of the auto-scaling group (default: 1).
* <b>asgmax:</b> Maximum size of the auto-scaling group (default: 5).
* <b>asgdesired:</b> Desired capacity of the auto-scaling group (default: 1).

# Outputs
This Terraform configuration does not explicitly define outputs, but it relies on outputs from the previous configuration <b>(fold1)</b> to get VPC, subnets, and security group details.

<b>Important:</b> Ensure that the Terraform state file from <b>file1</b> is correctly referenced in the <b>data "terraform_remote_state" "networking"</b> block in <b>file2/main.tf</b> for accurate resource data.
