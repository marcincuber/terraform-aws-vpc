# AWS VPC created with TERRAFORM templates

This repository contains a VPC setup to handle ipv4 and ipv6 traffic.
VPC consists of the following:

* Public routing table
	* with 3 public subnets in availability zone eu-west-1a/b/c
    * with attached internet gateway
* Private routing table
	* with 3 private subnets in availability zone eu-west-1a/b/c
	* NAT Gateway attached to allow routing out
	* Egress attached to allow ipv6 traffic
* Security group allows all traffic on ipv4 and ipv6
* AWS flow log enabled- Cloudwatch logging for the VPC; logging everything

NOTE: Make sure to specify a correct profile in `aws.tf` which needs to be configured in `~/.aws/credentials` and/or `~/.aws/config`.

## Usage

`env.tfvars` holds environment specific variables which should be set appropriatly.

### Validate
It is always good to validate templates with a simple command;
```
terraform validate
```
### Plan

```
terraform plan -var-file=env.tfvars
```

### Apply

```
terraform apply -var-file=env.tfvars
```

### Destroy

```
terraform destroy -var-file=env.tfvars
```

## Author

Marcin Cuber <marcincuber@hotmail.com>
