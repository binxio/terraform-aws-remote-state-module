output "remote_state_bucket_arn" {
  value       = aws_s3_bucket.remote_state.arn
  description = "The ARN of the S3 remote state bucket."
}

output "remote_replica_state_bucket_arn" {
  value       = aws_s3_bucket.remote_replica_state.arn
  description = "The ARN of the S3 remote replica state bucket."
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.dynamodb_table.arn
  description = "The ARN of the DynamoDB table."
}

output "replica_role_arn" {
  value       = aws_iam_role.replica_role.arn
  description = "The ARN of the replication role attached to the remote state bucket."
}
