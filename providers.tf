
/*
 To save the Terraform state file in S3 instead of a local folder, use the backend configuration before running `terraform init`
 Note that the "profile" is must be in your .aws/credentials file.
*/
/*
terraform {
  backend "s3" {
    bucket  = "terafrom-tfstate"
    key     = "static-website.tfstate"
    region  = "us-east-1"
    profile = "Add profile here"
  }

  required_version = ">=0.11.8"
}
*/

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

/*
 This provider is used to get the ACM certificate for the Cloudfront distribution. Since Cloudfront certificate can be added only from us-east-1 ACM.
*/
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "${var.aws_profile}"
}
