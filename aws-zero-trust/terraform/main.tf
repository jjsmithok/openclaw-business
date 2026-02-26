# AWS Zero-Terraform - Main Configuration
# This Terraform manages the AWS Organization

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  
  # Allow specifying different account for resources
  # Use profile = "default" or override with alias
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "email_domain" {
  description = "Email domain for AWS accounts"
  type        = string
  default     = "gmail.com"
}

# =====================================================
# OUTPUTS
# =====================================================

output "organization_info" {
  description = "AWS Organization Information"
  value = {
    org_id    = data.aws_organization.org.id
    master_id = data.aws_organization.org.master_account_id
  }
}

output "terraform_version" {
  value = terraform.version
}
