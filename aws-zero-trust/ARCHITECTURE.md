# AWS Zero-Trust Multi-Agent Architecture
## Version 2.0 - Aligned with Approved Baseline

> Status: Draft
> Date: 2026-02-26

---

## Executive Summary

This document describes a zero-trust AWS organization structure with 5 autonomous AI agents running as Kubernetes pods in the Control Tower account, using IAM Roles for Service Accounts (IRSA) with zero long-lived credentials.

---

## 1. AWS Organization Structure

```
AWS Organization Root (Payer Account)
│
├── 🏢 Management OU
│   └── Master Account (payer, billing)
│
├── 🔒 Security OU  
│   └── Security Tools Account
│       - GuardDuty, Inspector, WAF
│       - Security scanning
│
├── 📊 Logging OU
│   └── Central Logging Account
│       - CloudTrail
│       - Config
│       - S3 Audit Vault
│
├── 📈 Monitoring OU
│   └── Read-Only Monitoring Account
│       - Cross-account read-only roles
│       - Grafana dashboards
│       - No secrets, no write access
│
├── 🎛️ Control Tower OU
│   └── AI Enterprise Control Tower Account
│       - EKS Cluster 1.31+
│       - Kafka (Strimzi)
│       - ArgoCD
│       - Knative
│       - LangChain/Haystack
│       - 5 AI Agent Pods
│
└── 🏭 Environments OU
    ├── 🧪 Sandbox (auto-cleanup after 24h)
    ├── 💻 Dev
    ├── 🧬 Test
    ├── 🚀 Pre-Prod
    └── ⚠️ Prod (maximum restrictions)
```

---

## 2. Five Autonomous Agent Roles

### 2.1 Role Overview

| Agent | Role Name | Responsibilities | Environment |
|-------|-----------|-----------------|-------------|
| @security | `SecurityAgentRole` | IAM, GuardDuty, KMS, compliance | Control Tower |
| @network | `NetworkAgentRole` | VPC, Subnets, ALB, DNS | Control Tower |
| @infra | `InfraAgentRole` | EC2, RDS, S3, Backups | All Environment Accounts |
| @apps | `AppsAgentRole` | ECS, Lambda, CI/CD | All Environment Accounts |
| @member | `MemberAgentRole` | Identity, Federation, Self-service | Control Tower |

### 2.2 IRSA Configuration

Each agent runs as a Kubernetes pod that assumes an IAM role:

```yaml
# Example: Security Agent IRSA
apiVersion: eks.amazonaws.com/v1alpha1
kind: IAMRoleForServiceAccount
metadata:
  name: security-agent-role
  namespace: agents
spec:
  roleName: SecurityAgentRole
  serviceAccountName: security-agent
  conditions:
    - StringEquals:
        eks.amazonaws.com/subamespace: agents
        sts.amazonaws.com: AssumedRoleWithWebIdentity
```

### 2.3 Policy Example (SecurityAgentRole)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListUsers",
        "iam:ListRoles",
        "iam:ListPolicies",
        "guardduty:List*",
        "securityhub:List*",
        "kms:ListKeys"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:*Root*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 3. Service Control Policies (SCPs)

### 3.1 DenyRootLogin (Apply to All OUs)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootLogin",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalARN": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
```

### 3.2 DenyDirectHumanAccess (Production)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyHumanConsole",
      "Effect": "Deny",
      "Action": [
        "aws-portal:*Console*",
        "signin:*"
      ],
      "Resource": "*",
      "Condition": {
        "ArnNotLike": {
          "aws:PrincipalARN": "arn:aws:iam::*:role/BreakGlassRole"
        }
      }
    }
  ]
}
```

### 3.3 SandboxAutoCleanup

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AutoDeleteResources",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "rds:CreateDBInstance",
        "s3:CreateBucket"
      ],
      "Resource": "*",
      "Condition": {
        "DateGreaterThan": {
          "aws:CurrentTime": "2026-02-27T00:00:00Z"
        }
      }
    }
  ]
}
```

---

## 4. Network Architecture

### 4.1 Per-Account VPC Design

```
┌─────────────────────────────────────────────────────────────┐
│                   Each Account                              │
│                                                              │
│  VPC: 10.x.0.0/16                                          │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  Public Subnet   │  │  Private App    │                  │
│  │   (ALB, NAT)    │  │   Subnet        │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                              │
│  ┌─────────────────┐                                       │
│  │  Private Data   │                                       │
│  │   Subnet        │                                       │
│  │ (RDS, Elasti)  │                                       │
│  └─────────────────┘                                       │
│                                                              │
│  Transit Gateway → Central Network Account                   │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 CIDR Ranges (Avoid Overlap)

| Account | VPC CIDR | Public | Private App | Private Data |
|---------|----------|--------|-------------|--------------|
| Sandbox | 10.0.0.0/18 | .0/24 | .64/26 | .128/26 |
| Dev | 10.1.0.0/18 | .0/24 | .64/26 | .128/26 |
| Test | 10.2.0.0/18 | .0/24 | .64/26 | .128/26 |
| PreProd | 10.3.0.0/18 | .0/24 | .64/26 | .128/26 |
| Prod | 10.4.0.0/18 | .0/24 | .64/26 | .128/26 |

---

## 5. Control Tower EKS Cluster

### 5.1 Cluster Specs

- **Version**: Kubernetes 1.31
- **Nodes**: 3x m6i.xlarge (spot)
- **Add-ons**:
  - Cilium (CNI)
  - Karpenter (autoscaling)
  - ArgoCD (GitOps)
  - Kyverno (policy)
  - Strimzi (Kafka)
  - Knative (serverless)

### 5.2 Agent Pods

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: security-agent
  namespace: agents
spec:
  replicas: 1
  selector:
    matchLabels:
      app: security-agent
  template:
    metadata:
      labels:
        app: security-agent
    spec:
      serviceAccountName: security-agent
      containers:
      - name: agent
        image: openclaw/openclaw:latest
        env:
        - name: AWS_ROLE_ARN
          value: "arn:aws:iam::ACCOUNT_ID:role/SecurityAgentRole"
        - name: AWS_WEB_IDENTITY_TOKEN_FILE
          value: "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
```

---

## 6. Deployment Roadmap

### Phase 1: Organization (Day 1)
- [ ] Create AWS Organization
- [ ] Create OUs (Management, Security, Logging, Monitoring, Control, Environments)
- [ ] Create member accounts (via Terraform/OpenTofu)

### Phase 2: SCPs (Day 1)
- [ ] Apply DenyRootLogin SCP
- [ ] Apply DenyDirectHumanAccess to Prod
- [ ] Apply SandboxAutoCleanup to Sandbox

### Phase 3: Control Tower (Day 2)
- [ ] Deploy EKS cluster
- [ ] Install add-ons (ArgoCD, Karpenter, etc.)
- [ ] Configure IRSA for agents

### Phase 4: Agent Deployment (Day 3)
- [ ] Deploy 5 agent pods
- [ ] Configure cross-account access
- [ ] Test webhook integration

### Phase 5: First Deployment (Day 5)
- [ ] Test Change Board webhook
- [ ] Deploy to Sandbox
- [ ] Verify auto-cleanup

---

## 7. Cost Estimate

| Component | Monthly Cost |
|-----------|-------------|
| EKS Cluster (3x spot) | ~$150 |
| NAT Gateways (5 accounts) | ~$175 |
| CloudTrail | ~$20 |
| GuardDuty | ~$10 |
| S3 (minimal) | ~$10 |
| **Total** | **~$365/month** |

---

## 8. Zero-Trust Principles Implemented

1. ✅ **Never trust, always verify** - IRSA with web identity
2. ✅ **Least privilege** - Agent-specific IAM policies
3. ✅ **Assume breach** - Micro-segmentation, no implicit trust
4. ✅ **Verify explicitly** - All actions via GitOps/webhooks
5. ✅ **Micro-segmentation** - Per-account VPC, security groups
6. ✅ **Zero human access** - SCPs deny console except break-glass
7. ✅ **Audit everything** - CloudTrail to centralized logging

---

## 9. Implementation Files

See `/aws-zero-trust/` directory:

- `terraform/` - OpenTofu modules
- `policies/` - IAM policies
- `scps/` - Service Control Policies
- `k8s/` - Kubernetes manifests

---

*Document Status: Ready for Implementation*
*Last Updated: 2026-02-26*
