resource "aws_secretsmanager_secret" "db_password_secret" {
  # name        = "db-password-rds-6"
  name        = "db-password-rds-${replace(timestamp(), ":", "-")}"
  description = "Database password for the RDS instance"
  kms_key_id  = aws_kms_key.secrets_key.arn
}

resource "random_password" "db_password" {
  length           = 10
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  override_special = ""
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = jsonencode({ "password" = random_password.db_password.result })
}


resource "aws_secretsmanager_secret" "email_service_secret" {
  name        = "email-service-secret-${replace(timestamp(), ":", "-")}"
  description = "Email service credentials for the Lambda function"
  kms_key_id  = aws_kms_key.secrets_key.arn
}

resource "aws_secretsmanager_secret_version" "email_service_secret_version" {
  secret_id = aws_secretsmanager_secret.email_service_secret.id
  secret_string = jsonencode({
    SENDGRID_API_KEY = var.email_key
    EMAIL_FROM       = var.email_from
  })
}
