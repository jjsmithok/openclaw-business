# AWS Zero-Trust Terraform - Import Existing + Create IAM Users
# This terraform imports existing AWS accounts and creates IAM users for agents

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

# =====================================================
# CONFIGURATION - Hardcoded IDs from AWS
# =====================================================

locals {
  root_id           = "r-mtuq"
  environments_ou_id = "ou-mtuq-8md6m2ul"
  org_id            = "o-h6abhtplft"
  
  # Existing account IDs
  existing_accounts = {
    sandbox    = "605412636532"
    dev        = "811890957660"
    test       = "949900383634"
    preprod    = "490058394713"
    prod       = "693099116199"
    security   = "853962316430"
    monitoring = "930975754172"
    logging    = "263751250645"
    control    = "876442841338"
  }
}

# =====================================================
# IAM USERS FOR AGENTS
# =====================================================

resource "aws_iam_user" "security_agent" {
  name = "openclaw-security"
}

resource "aws_iam_user" "network_agent" {
  name = "openclaw-network"
}

resource "aws_iam_user" "infra_agent" {
  name = "openclaw-infra"
}

resource "aws_iam_user" "apps_agent" {
  name = "openclaw-apps"
}

# Create access keys for agents
resource "aws_iam_access_key" "security_agent" {
  user = aws_iam_user.security_agent.name
}

resource "aws_iam_access_key" "network_agent" {
  user = aws_iam_user.network_agent.name
}

resource "aws_iam_access_key" "infra_agent" {
  user = aws_iam_user.infra_agent.name
}

resource "aws_iam_access_key" "apps_agent" {
  user = aws_iam_user.apps_agent.name
}

# Attach read-only policies
resource "aws_iam_user_policy_attachment" "security_readonly" {
  user       = aws_iam_user.security_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "network_readonly" {
  user       = aws_iam_user.network_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "infra_readonly" {
  user       = aws_iam_user.infra_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "apps_readonly" {
  user       = aws_iam_user.apps_agent.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# =====================================================
# OUTPUTS
# =====================================================

output "organization_id" {
  value = local.org_id
}

output "environments_ou_id" {
  value = local.environments_ou_id
}

output "existing_environment_accounts" {
  value = local.existing_accounts
}

output "agent_users" {
  value = {
    security = aws_iam_user.security_agent.name
    network  = aws_iam_user.network_agent.name
    infra    = aws_iam_user.infra_agent.name
    apps     = aws_iam_user.apps_agent.name
  }
}

output "agent_access_keys" {
  description = "Access key IDs"
  value = {
    security = aws_iam_access_key.security_agent.id
    network  = aws_iam_access_key.network_agent.id
    infra    = aws_iam_access_key.infra_agent.id
    apps     = aws_iam_access_key.apps_agent.id
  }
}
