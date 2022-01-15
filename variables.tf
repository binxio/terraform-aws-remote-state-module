variable "bucket_name" {
  type        = string
  description = "A name for the S3 bucket."

  validation {
    condition     = length(var.bucket_name) > 3 && length(var.bucket_name) < 50
    error_message = "The bucket name must be between 4 and 50 characters long."
  }
}

variable "dynamodb_table_name" {
  type        = string
  description = "A name for the DynamoDB table."
}

variable "tags" {
  type        = map(any)
  description = "A set of tags that should be attached to the resources."
}
