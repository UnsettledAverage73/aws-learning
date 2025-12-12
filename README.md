# AWS Cloud & Terraform Learning Journey

## Project Overview
This repository documents a progressive learning path for AWS Cloud Infrastructure using Terraform (Infrastructure as Code). The project evolves from basic compute provisioning to complex serverless architectures and custom networking.

**Primary Goal:** To master AWS services (EC2, S3, Lambda, DynamoDB, VPC) while adhering to FinOps principles (Zero-Spend) and overcoming real-world permission boundaries in restricted environments (Student Labs).

---

## 🏗 Architecture Evolution

### Phase 1: Compute & Infrastructure as Code (IaaC)
We began by automating the deployment of virtual machines, moving from manual console clicks to reproducible code.
* **Services:** AWS EC2, Security Groups, Key Pairs.
* **Key Achievement:** Automated the provisioning of an Apache Web Server on Ubuntu using User Data scripts.
* **Refactoring:** Transitioned from a monolithic `main.tf` to a modular structure (`variables.tf`, `outputs.tf`) to support multi-region deployments.

### Phase 2: Serverless Web Application (3-Tier Architecture)
We migrated from managing servers to a modern Serverless architecture to reduce cost and operational overhead.
* **Frontend:** Static website hosting on **Amazon S3**.
* **Compute:** Python backend logic running on **AWS Lambda**.
* **Database:** NoSQL visitor counter using **Amazon DynamoDB**.
* **Integration:** Frontend communicates with Backend via public **Lambda Function URLs**.

### Phase 3: Custom Networking (VPC)
We moved away from the "Default VPC" to build a secure, isolated network foundation.
* **Components:** Custom VPC, Public Subnets, Internet Gateways (IGW), and Route Tables.

---

## 📂 Repository Structure

```text
.
├── aws-ec2-learning/          # Phase 1: Virtual Machines
│   ├── main.tf                # Resource definitions (EC2, SG)
│   ├── variables.tf           # Dynamic inputs (Region, Instance Type)
│   ├── outputs.tf             # Return values (Public IP, URL)
│   └── terraform.tfvars       # (Ignored) Environment-specific overrides
│
├── aws-s3-serverless/         # Phase 2: Serverless App
│   ├── main.tf                # S3, Lambda, DynamoDB, IAM
│   ├── hello.py               # Python backend logic
│   └── index.html             # Frontend with JS fetch logic
│
└── aws-vpc-learning/          # Phase 3: Networking
    └── main.tf                # VPC, Subnets, Route Tables

```
###  Challenge,Error / Symptom,Solution
* SSH Access,Permission denied (publickey),Fixed local key permissions (chmod 400) and corrected OS username (ec2-user vs ubuntu).
* Region Lock,UnauthorizedOperation in us-east-2,Detected Student Lab restrictions; reverted deployment to us-east-1 (N. Virginia).
* IAM Privileges,iam:CreateRole Access Denied,Replaced resource creation with a data source to utilize the pre-existing LabRole.
* S3 Policy,s3:GetBucketPolicy Access Denied,Utilized Terraform target flags (-target=...) to bypass blocked S3 read operations and deploy only Lambda/DynamoDB.


# 🛠 Usage Instructions
Prerequisites
Terraform installed (v1.x+)

AWS CLI configured with credentials

Git

1. Deploying Compute (EC2)
```Bash
cd aws-ec2-learning
terraform init
terraform apply
```

# Output: Website URL and Public IP
2. Deploying Serverless App
Note: In restricted lab environments, use the target flag if S3 errors occur.

```
```Bash

cd aws-s3-serverless
terraform init
terraform apply -target=aws_lambda_function.test_lambda -target=aws_dynamodb_table.
```
visitors
# Output: Lambda Function URL
3. Cleaning Up (Cost Management)
To prevent unexpected AWS charges, always destroy resources after the session.

Bash

terraform destroy --auto-approve
💡 Lessons Learned
Ephemerality: Infrastructure should be treated as disposable. We successfully destroyed and rebuilt environments in minutes.

State Management: Never commit .tfstate files to GitHub; they contain secrets.

Permission Boundaries: "Smart" code (Data Sources) sometimes fails in strict environments. Hardcoding is an acceptable fallback when permissions are denied.

Separation of Concerns: Decoupling logic (main.tf) from data (variables.tf) makes code reusable across regions.

Author: UnsettledAverage73 Status: Ongoing Learning
