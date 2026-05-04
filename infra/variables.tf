variable "db_username" {
  description = "Username para o RDS"
  type        = string
  sensitive   = true # Isso impede que o valor apareça nos logs do terminal
}

variable "db_password" {
  description = "Password para o RDS"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "E-mail que receberá os alertas de custo do AWS Budget"
  type        = string
}
