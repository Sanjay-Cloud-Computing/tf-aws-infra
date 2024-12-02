# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name = "LambdaExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "sns:Publish"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      },
      {
        "Sid" : "AllowLambdaAccess",
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds-db:connect"
        ],
        Resource = aws_db_instance.rds_instance.arn
      }
    ]
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "email_verification_function" {
  filename      = "/Users/sanjay/Desktop/lambda_function.zip"
  function_name = "email_verification_function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  # source_code_hash = filebase64sha256("serverless.zip")

  environment {
    variables = {

      # SENDGRID_API_KEY = var.email_key
      EMAIL_SECRET_NAME = aws_secretsmanager_secret.email_service_secret.name
      BASE_URL          = var.base_url
      EMAIL_FROM        = var.email_from
    }
  }

  tags = {
    Environment = "dev"
    Name        = "EmailVerificationLambda"
  }
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_creation_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification_function.arn

  depends_on = [aws_lambda_function.email_verification_function]
}

resource "aws_lambda_permission" "sns_invocation_permission" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_creation_topic.arn
}

