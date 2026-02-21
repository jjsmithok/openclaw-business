# Customer Onboarding Flow

## Step 1: Initial Contact
- Customer reaches out (website form, email, or messaging)
- Gather: name, use case, preferred messaging app, technical comfort level

## Step 2: Plan Selection
- Recommend tier based on needs
- Send quote/payment link

## Step 3: Payment
- Stripe invoice or payment link
- Confirm payment received

## Step 4: Provisioning (Automated where possible)
1. Provision VPS via provider API (or guide customer)
2. Generate secure config (passwords, API keys)
3. Install OpenClaw via curl/Docker
4. Configure messaging integration
5. Set up basic skills
6. Apply security hardening

## Step 5: Testing
- Verify messaging connection works
- Test basic commands
- Confirm skills functional

## Step 6: Handover
- Send access instructions
- Provide quick start guide
- Schedule onboarding call (for Pro/Enterprise)

## Step 7: Ongoing
- Add to monitoring
- Schedule regular check-ins
- Handle support requests

---

## Automation Opportunities
- VPS provisioning: Use provider APIs (DigitalOcean, Hetzner)
- Config generation: Script/template-based
- Security hardening: Ansible or shell scripts
- Testing: Automated test scripts
- Monitoring: Prometheus + Grafana or simple cron checks
