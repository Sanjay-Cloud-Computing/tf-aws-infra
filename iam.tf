resource "aws_iam_role" "ec2_role" {
  name = "ec2-cloudwatch-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "EC2CloudWatchS3Policy"
  description = "Policy for EC2 to access CloudWatch and S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.file_upload_bucket.bucket}/*"
      },
      {
        Effect : "Allow",
        Action : "*",
        Resource : "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
      ,
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_access_policy" {
  name        = "KMSAccessPolicy"
  description = "Allow EC2 instances to use the KMS key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        Resource : aws_kms_key.ec2_key.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_access_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_role_profile" {
  name = "ec2-cloudwatch-s3-profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_iam_policy" "lambda_secrets_policy" {
  name        = "LambdaSecretsAccessPolicy"
  description = "Allow Lambda to access email credentials in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue"
        ],
        Resource : aws_secretsmanager_secret.email_service_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}
