# Terraform variables for OpenClaw EC2
# Copy this file to terraform.tfvars and fill in your values

# AWS credentials for OpenClaw (needs IAM user credentials)
aws_access_key = ""  # Set your AWS access key
aws_secret_key = ""  # Set your AWS secret key

# MiniMax API Key
minimax_api_key = ""  # Set your MiniMax API key

# Telegram Bot Token
telegram_bot_token = ""  # Set your Telegram bot token

# Optional overrides
instance_type    = "t3.medium"
openclaw_version = "2026.2.26"
ssh_key_name     = "openclaw-agent"
