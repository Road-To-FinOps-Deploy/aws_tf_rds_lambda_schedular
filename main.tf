#Generating the zip files
data "archive_file" "rds_scheduler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/rds_scheduler.py"
  output_path = "${path.module}/output/rds_scheduler.zip"
}

resource "aws_lambda_function" "rds_start" {
  filename         = "${path.module}/output/rds_scheduler.zip"
  function_name    = "${var.function_prefix}scheduler_rds_start"
  role             = aws_iam_role.iam_role_for_rds_start_stop.arn
  handler          = "rds_scheduler.start_lambda_handler"
  source_code_hash = data.archive_file.rds_scheduler_zip.output_base64sha256
  runtime          = "python3.7"
  memory_size      = "128"
  timeout          = "150"

  environment {
    variables = {
      TAG_KEY   = var.rds_tag_key
      TAG_VALUE = var.rds_tag_value
    }
  }
}

resource "aws_lambda_function" "rds_stop" {
  filename         = "${path.module}/output/rds_scheduler.zip"
  function_name    = "${var.function_prefix}scheduler_rds_stop"
  role             = aws_iam_role.iam_role_for_rds_start_stop.arn
  handler          = "rds_scheduler.stop_lambda_handler"
  source_code_hash = data.archive_file.rds_scheduler_zip.output_base64sha256
  runtime          = "python3.7"
  memory_size      = "128"
  timeout          = "150"

  environment {
    variables = {
      TAG_KEY   = var.rds_tag_key
      TAG_VALUE = var.rds_tag_value
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_rds_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_start.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_start_cloudwatch_rule.arn

  depends_on = [aws_lambda_function.rds_start]
}

resource "aws_lambda_permission" "allow_cloudwatch_rds_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_stop_cloudwatch_rule.arn

  depends_on = [aws_lambda_function.rds_stop]
}

resource "aws_cloudwatch_event_rule" "rds_start_cloudwatch_rule" {
  name                = "${var.function_prefix}scheduler_rds_start_lambda_trigger"
  schedule_expression = var.start_cron
}

resource "aws_cloudwatch_event_target" "rds_start_lambda" {
  rule      = aws_cloudwatch_event_rule.rds_start_cloudwatch_rule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.rds_start.arn
}

resource "aws_cloudwatch_event_rule" "rds_stop_cloudwatch_rule" {
  name                = "${var.function_prefix}scheduler_rds_stop_lambda_trigger"
  schedule_expression = var.stop_cron
}

resource "aws_cloudwatch_event_target" "rds_stop_lambda" {
  rule      = aws_cloudwatch_event_rule.rds_stop_cloudwatch_rule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.rds_stop.arn
}

