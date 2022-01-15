locals {
  tags = merge(var.tags, {
    "module" : "github.com/binxio/terraform-aws-remote-state-module",
  })
  dynamodb_lock_attribute = "LockID"
}
