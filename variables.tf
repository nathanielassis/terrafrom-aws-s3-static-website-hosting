variable aws_region {
  description = "The AWS region to deploy the AWS resources"
  default = "us-east-1"
}

variable aws_profile {
  description = "The terraform profile in your .aws/credentials file to use for deployment"
  default = "default"
}

variable acm_cert_domain {
  description = "The domain of the certificate to look up. If no certificate is found with this name, an error will be returned"
  default = "acme.io"
}

variable "app_name" {
  description = "The Static website application name, for example: myapp"
  default = "myapp"
}

variable "forward-query-string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior"
  default     = "false"
}

variable "hosted_zone_domain_name" {
  description = "Specify the hosted zone domain name, for example: cdn.acme.io"
  default     = "acme.io"
}

variable "enable_r53_healthcheck" {
  description = "Enable route53 healthcheck, true/false"
  default = false
}

variable "alarm_action" {
  description = "Arn of alarm action such as an sns topic"
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "Optional Tags"
  default     = {}
}
