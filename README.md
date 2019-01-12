# AWS Static Website hosting

Use this repository to create AWS static website which includes the following:  
- Cloudfront distribution  
- A hardened **Private** S3 bucket origin  
- Route53 Alias record

**IMPORTANT:** 
- **change the variables values according to your requirements**

## Pre requisites
- ACM certificate in us-east-1 for the Cloudfront distribution
- Route53 hosted zone

## USAGE

```
terraform init
terraform [plan, apply]
```


## Healthchecks

For production environments Route53 health checks can be enabled with enable_r53_healthcheck if requested.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acm_cert_domain | The domain of the certificate to look up. If no certificate is found with this name, an error will be returned | string | `acme.io` | no |
| alarm_action | Arn of alarm action such as an sns topic | string | `` | no |
| app_name | The Static website application name, for example: myapp | string | `myapp` | no |
| aws_profile | The terraform profile in your .aws/credentials file to use for deployment | string | `default` | no |
| aws_region | The AWS region to deploy the AWS resources | string | `us-east-1` | no |
| enable_r53_healthcheck | Enable route53 healthcheck, true/false | string | `false` | no |
| forward-query-string | Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior | string | `false` | no |
| hosted_zone_domain_name | Specify the hosted zone domain name, for example: cdn.acme.io | string | `acme.io` | no |
| tags | Optional Tags | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| website_bucket_arn |  |
| website_bucket_id |  |
| website_cdn_arn | The cloudfront distribution ARN |
| website_cdn_hostname | The cloudfront distribution domain name |
| website_cdn_id | The cloudfront distribution id |
| website_cdn_zone_id |  |


