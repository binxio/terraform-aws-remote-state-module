# Terraform AWS Remote Backend module

Module that allows you to provision a cross-region remote backend for AWS.

After running `terraform apply` add a s3 `backend` as following:

```hcl
terraform {
  backend "s3" {
    bucket         = "a-remote-state-bucket"
    dynamodb_table = "a-state-lock-table"
    key            = "my/terraform-state/key"
    region         = "eu-west-1"
    encrypt        = true
  }
}
```

## Features

- S3 cross-region replication
- Denies object deletion
- Enforces encryption in transit and at rest

## Usage

### Remote backend configuration

```hcl
provider "aws" {
  region  = "eu-central-1"
}

provider "aws" {
  alias  = "replica"
  region = "eu-west-1"
}

module "remote_backend" {
  source              = "github.com/binxio/terraform-aws-remote-state-module"
  bucket_name         = "a-remote-state-bucket"
  dynamodb_table_name = "a-state-lock-table"
  tags = {
    "Key" = "Value"
  }
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.72.0 |
| <a name="provider_aws.replica"></a> [aws.replica](#provider\_aws.replica) | 3.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.replica_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replica_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replica_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.remote_replica_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.remote_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.remote_replica_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.remote_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | A name for the S3 bucket. | `string` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | A name for the DynamoDB table. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of tags that should be attached to the resources. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | The ARN of the DynamoDB table. |
| <a name="output_remote_replica_state_bucket_arn"></a> [remote\_replica\_state\_bucket\_arn](#output\_remote\_replica\_state\_bucket\_arn) | The ARN of the S3 remote replica state bucket. |
| <a name="output_remote_state_bucket_arn"></a> [remote\_state\_bucket\_arn](#output\_remote\_state\_bucket\_arn) | The ARN of the S3 remote state bucket. |
| <a name="output_replica_role_arn"></a> [replica\_role\_arn](#output\_replica\_role\_arn) | The ARN of the replication role attached to the remote state bucket. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

## Authors

Module managed by [Bruno Schaatsbergen](https://github.com/bschaatsbergen).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/binxio/terraform-aws-remote-state-module/tree/main/LICENSE).
