resource "aws_budgets_budget" "custo_fortaleza" {
  name         = "alerta-custo-fortaleza-digital"
  budget_type  = "COST"
  limit_amount = "1.0"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email] # Coloque seu e-mail aqui
  }
}
