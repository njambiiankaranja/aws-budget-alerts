# AWS Budget Alerts with Terraform

Terraform project that creates a monthly AWS cost budget and emails you when spending crosses set thresholds, so an unexpected bill never comes as a surprise.

---

## The Problem It Solves

Cloud resources bill by the hour or by the request, and it is easy to leave something running or to run up usage without noticing. A forgotten NAT Gateway or EC2 instance can cost real money before the monthly invoice arrives. A budget with alerts turns that into an early warning, and defining it in Terraform means it is set up the same way every time and is never forgotten.

---

## What It Does

Creates one monthly cost budget for the AWS account and sends an email to the address you choose:

| Alert | Triggers when |
|---|---|
| 50% actual | Half of the monthly limit has been spent |
| 80% actual | 80 percent of the monthly limit has been spent |
| 100% forecasted | AWS predicts the month will end over the limit |

The limit is set with a variable and defaults to 5 US dollars.

---

## Architecture

```text
 AWS account spending
        |
        v
 AWS Budgets (monthly cost budget)
        |  checks actual and forecasted spend
        v
 Email alert at 50%, 80% and forecasted 100%
```

Alerts go straight to your email address through AWS Budgets, so there is no extra topic or subscription to confirm.

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `alert_email` | none, required | Address that receives the alerts |
| `monthly_budget_usd` | `5` | Monthly limit in US dollars. Alert thresholds are percentages of this amount |
| `aws_region` | `us-east-1` | Region for the Terraform provider |
| `project_name` | `budget-alerts` | Prefix for the budget name and the `Project` tag |

### Outputs

| Output | Description |
|---|---|
| `budget_name` | Name of the monthly cost budget |
| `budget_limit_usd` | Monthly limit in US dollars |

---

## Things to Know

- **Alerts are warnings, not limits.** A budget does not stop anything from running. It only tells you, so you still need to act on the email.
- **Billing data is delayed.** AWS updates cost data a few times a day, so an alert can arrive hours after the spending happened.
- **The forecast alert needs history.** AWS needs some past usage to make a prediction, so on a very new account the forecasted alert may not fire yet. The two actual-spend alerts work straight away.
- **It covers the whole account.** The budget tracks total spending, not a single project.
- **Free tier of budgets.** AWS includes a small number of budgets per account at no charge. Check the current AWS pricing page before adding more.

---

## Project Structure

```text
aws-budget-alerts/
├── main.tf         # Monthly cost budget and notifications
├── variables.tf    # Email, monthly limit, region, project name
├── outputs.tf      # Budget name and limit
├── providers.tf    # Provider versions and S3 remote backend
└── README.md
```

---

## Deployment

Prerequisites: an AWS account with the AWS CLI configured, Terraform `>= 1.0.0`, permission to manage AWS Budgets, and an S3 bucket for remote state (set in `providers.tf`, and it must exist before `terraform init`).

Create a `terraform.tfvars` file (ignored by Git):

```hcl
alert_email        = "you@example.com"
monthly_budget_usd = 5
```

Then deploy:

```bash
terraform init
terraform plan
terraform apply
```

You can confirm the budget in the AWS console under Billing and Cost Management, then Budgets.

### Tear down

```bash
terraform destroy
```

This removes the budget and its alerts, so only run it if you no longer want them.

---

## Ideas for Extending It

- Add a budget per service, such as EC2 or data transfer, with its own thresholds
- Send alerts to an SNS topic so they reach Slack or a phone as well as email
- Add AWS Budgets actions that apply a restrictive policy when the limit is passed
- Add a GitHub Actions workflow that runs `terraform fmt` and `validate` on every pull request