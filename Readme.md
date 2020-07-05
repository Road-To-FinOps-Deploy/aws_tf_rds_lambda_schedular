# Lambda Scheduler
```
The script schedules the start/stop of RDS instances and Aurora clusters based on db tags.
```

**Tag** your rds instances or aurora cluster with the tag: **'xxxx': 'onoff'**
'xxxx' - key can be anything, as it is variable in this module (see below). Default is 'RDSLambdaSchedule'

Remember this use UCT Time

```
Usage
module "aws_rds_lambda_scheduler" {
    source         = "git::https://terraform-readonly:XYZ@stash.customappsteam.co.uk/scm/ter/aws_rds_lambda_scheduler.git/?ref=vXYZ"

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_region |  | string | `"eu-west-1"` | no |
| enabled | Enable that module or not | string | `"1"` | no |
| function\_prefix | Prefix for the name of the resources created | string | `""` | no |
| start\_cron | Rate expression for when to run the start RDS lambda | string | `"cron(0 7 ? * MON-FRI *)"` | no |
| start\_cron | Rate expression for when to run the stop RDS | string | `"cron(0 21 ? * MON-FRI *)"` | no |
| rds\_tag\_key | Key of the RDS tagged instance | string | `"rds_lambda_scheduled"` | no |
| rds\_tag\_value | Value of the RDS tagged instance | string | `"onoff"` | no |

## Change history
v4.0: 2019-07-29

- Have added environment variable to Lambda function resource block, rather than this being set in .py file. 
- Default values for 'TAG_KEY' is 'rds_lambda_scheduled'     
- Default value for 'TAG_VALUE' is 'onoff'

v3.3: 2019-07-22

- RDS instance must be tagged with 'nightly':'onoff'