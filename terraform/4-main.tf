# AWS Budget resource
resource "aws_budgets_budget" "linux-sandbox" {
  name              = "linux-sandbox-budget"
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-04-04_20:00"
}