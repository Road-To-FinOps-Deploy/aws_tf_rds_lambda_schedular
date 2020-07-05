resource "aws_iam_role" "iam_role_for_rds_start_stop" {
  count              = "${var.enabled}"
  name               = "${var.function_prefix}iam_role_rds_start_stop"
  assume_role_policy = "${file("${local.module_relpath}/policies/LambdaAssume.pol")}"
}

resource "aws_iam_role_policy" "iam_role_policy_for_rds_start_stop" {
  count  = "${var.enabled}"
  name   = "ExecuteLambda"
  role   = "${aws_iam_role.iam_role_for_rds_start_stop.id}"
  policy = "${file("${local.module_relpath}/policies/LambdaExecution.pol")}"
}
