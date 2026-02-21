# Stripe Payment Setup Guide

## Step 1: Create Stripe Account
1. Go to [stripe.com](https://stripe.com)
2. Click "Start now" → sign up with email
3. Complete account verification (business name, bank details)

## Step 2: Create Payment Links

### Beta Setup ($149)
1. In Stripe dashboard → **Products** → **Create product**
2. Name: "OpenClaw Beta Setup"
3. Price: $149.00 (one-time)
4. Save product

5. Go to **Payment Links** → **Create link**
6. Select the product
7. Copy the link (e.g., `buy.stripe.com/xxx`)

### Monthly Hosting ($79/mo)
1. Create product: "OpenClaw Monthly Hosting"
2. Price: $79.00 (recurring, monthly)
3. Create payment link

## Step 3: Test Mode
- Use Stripe test cards: 4242 4242 4242 4242
- Test links start with `buy.stripe.com/test_...`

## Step 4: Add to Landing Page
Replace `#payment-link` in the HTML with your actual Stripe payment links.

---

## Quick Links to Create
| Product | Price | Type | Link |
|---------|-------|------|------|
| Beta Setup | $149 | One-time | (create) |
| Hosting | $79/mo | Recurring | (create) |
