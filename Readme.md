# Lambda Scheduler
```
The script schedules the start/stop of RDS instances and Aurora clusters based on db tags.
```

Remember this use UCT Time

```
Usage
module "aws_rds_lambda_scheduler" {
    source         = ""

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_region |  | string | `"eu-west-1"` | no |
| function\_prefix | Prefix for the name of the resources created | string | `""` | no |
| start\_cron | Rate expression for when to run the start RDS lambda | string | `"cron(0 7 ? * MON-FRI *)"` | no |
| start\_cron | Rate expression for when to run the stop RDS | string | `"cron(0 21 ? * MON-FRI *)"` | no |
| rds\_tag\_key | Key of the RDS tagged instance | string | `"nightly"` | no |
| rds\_tag\_value | Value of the RDS tagged instance | string | `"onoff"` | no |


- RDS instance must be tagged with 'nightly':'onoff'

## Testing 

Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
1. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.
1. Install [Golang](https://golang.org/) and make sure this code is checked out into your `GOPATH`.
cd test
go mod init github.com/sg/sch
go test -v -run TestTerraformAws