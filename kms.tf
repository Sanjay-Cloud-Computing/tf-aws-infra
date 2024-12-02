resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
       
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}
 
EOF

}

resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/ec2-key"
  target_key_id = aws_kms_key.ec2_key.key_id
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
        {
            "Sid": "AllowRootAccountAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "AllowRDSAccessViaCloudWatchRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-cloudwatch-s3-role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowRDSAccess",
            "Effect": "Allow",
            "Principal": {
                "Service": "rds.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF



}


resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
     
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-cloudwatch-s3-role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-cloudwatch-s3-role"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}
 
 
  EOF


}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
   
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_execution_role"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}
 
EOF
}
resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/secrets-key"
  target_key_id = aws_kms_key.secrets_key.key_id
}
