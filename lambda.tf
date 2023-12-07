#################################################################
# CREATE ORDER LAMBDA
#################################################################

data "aws_iam_policy" "lambda_basic_executionrole" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "create_order_lambda_functionrole" {
  name = "create_order_lambda_functionrole"
  managed_policy_arns = [
    data.aws_iam_policy.lambda_basic_executionrole.arn,
    aws_iam_policy.create_order_lambda_policy.arn
  ]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "create_order_lambda_policy_document" {
  statement {

    effect = "Allow"

    actions = [
      "sqs:SendMessage*"
    ]

    resources = [
      aws_sqs_queue.process_order_queue.arn
    ]
  }
}

resource "aws_iam_policy" "create_order_lambda_policy" {
  name_prefix = "lambda_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.create_order_lambda_policy_document.json
  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "function_archive_create_order" {
  type        = "zip"
  source_file = local.binary_path_create_order
  output_path = local.archive_path_create_order
}

resource "aws_lambda_function" "create_order" {
  function_name = "create-order"
  description   = "Lambda function for create order"
  role          = aws_iam_role.create_order_lambda_functionrole.arn
  handler       = local.binary_name_create_order
  memory_size   = 128
  timeout       = 30

  filename         = local.archive_path_create_order
  source_code_hash = data.archive_file.function_archive_create_order.output_base64sha256

  runtime = "go1.x"
  environment {
    variables = {
      SQS_QUEUE_NAME = aws_sqs_queue.process_order_queue.url
    }
  }
}

#################################################################
# PROCESS ORDER LAMBDA
#################################################################

# Role to execute lambda
resource "aws_iam_role" "process_order_lambda_functionrole" {
  name               = "process_order_lambda_functionrole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "process_order_lambda_policy_document" {
  name   = "process_order_lambda_policy_document"
  path   = "/"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.process_order_queue.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "process_order_policy_attachment" {
  role       = aws_iam_role.process_order_lambda_functionrole.name
  policy_arn = aws_iam_policy.process_order_lambda_policy_document.arn
}

data "archive_file" "function_archive_process_order" {
  type        = "zip"
  source_file = local.binary_path_process_order
  output_path = local.archive_path_process_order
}

resource "aws_lambda_function" "process_order" {
  function_name = "process-order"
  description   = "Lambda function for processing order"
  role          = aws_iam_role.process_order_lambda_functionrole.arn
  handler       = local.binary_name_process_order
  memory_size   = 128
  timeout       = 30

  filename         = local.archive_path_process_order
  source_code_hash = data.archive_file.function_archive_process_order.output_base64sha256

  runtime = "go1.x"
  environment {
    variables = {
      SQS_QUEUE_NAME = aws_sqs_queue.process_order_queue.url
    }
  }
}

resource "aws_lambda_event_source_mapping" "process_sqs_lambda_sourcemapping" {
  event_source_arn = aws_sqs_queue.process_order_queue.arn
  function_name    = aws_lambda_function.process_order.function_name
}
