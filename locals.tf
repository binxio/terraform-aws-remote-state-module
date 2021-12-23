locals {
  tags = merge(var.tags, {
    "module" : "github.com/binxio/terraform-aws-remote-state-module",
  })
  dynamodb_lock_attribute = "LockID" # See: https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
}
