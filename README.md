# Terraform AWS Remote Backend module

This module is still under development.

## Features

-
-
-

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

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

## Authors

Module managed by [Bruno Schaatsbergen](https://github.com/bschaatsbergen).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/binxio/terraform-aws-remote-state-module/tree/main/LICENSE).
