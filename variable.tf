variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # Free tier eligible
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "deployer-key"
}
