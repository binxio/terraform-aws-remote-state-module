locals {
  remote_replica_state_bucket_name = "${var.bucket_name}-replica"
  tags = merge(var.tags, {
    "module" : "github.com/binxio/terraform-aws-remote-state-module",
  })
  dynamodb_lock_attribute = "LockID"
}
