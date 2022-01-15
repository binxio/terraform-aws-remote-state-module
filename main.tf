resource "aws_s3_bucket" "remote_state" {
  bucket = var.bucket_name
  acl    = "private"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "TerraformStateBucketPolicy",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": true
        }
      }
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "DenyObjectDeletion",
      "Effect": "Deny",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ]
    }
  ]
}
POLICY

  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.replica_role.arn

    rules {
      id     = "${var.bucket_name}-replication-rule"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.remote_replica_state.arn
        storage_class = "STANDARD"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "remote_replica_state" {
  bucket = local.remote_replica_state_bucket_name
  acl    = "private"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "TerraformStateBucketPolicy",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.remote_replica_state_bucket_name}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.remote_replica_state_bucket_name}/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": true
        }
      }
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${local.remote_replica_state_bucket_name}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "DenyObjectDeletion",
      "Effect": "Deny",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${local.remote_replica_state_bucket_name}/*",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ]
    }
  ]
}
POLICY

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true
  provider      = aws.replica
}

resource "aws_s3_bucket_public_access_block" "remote_replica_state" {
  bucket = aws_s3_bucket.remote_replica_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  provider = aws.replica
}


resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = local.dynamodb_lock_attribute

  attribute {
    name = local.dynamodb_lock_attribute
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}

resource "aws_iam_role" "replica_role" {
  name = "${var.bucket_name}-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replica_policy" {
  name = "${var.bucket_name}-replication-role-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.remote_state.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.remote_state.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.remote_replica_state.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replica_policy" {
  role       = aws_iam_role.replica_role.name
  policy_arn = aws_iam_policy.replica_policy.arn
}
