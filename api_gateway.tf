resource "aws_apigatewayv2_api" "create_order" {
  name          = "create-order"
  protocol_type = "HTTP"
  description   = "API Gateway ingress for create order lambda function"

  cors_configuration {
    allow_headers  = ["*"]
    allow_methods  = ["POST"]
    allow_origins  = ["*"] // for simplicity
    expose_headers = []
    max_age        = 0
  }
}

resource "aws_apigatewayv2_stage" "create_order" {
  api_id = aws_apigatewayv2_api.create_order.id

  name        = "app"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "create_order_lambda" {
  api_id = aws_apigatewayv2_api.create_order.id

  integration_uri  = aws_lambda_function.create_order.arn
  integration_type = "AWS_PROXY"
}

resource "aws_apigatewayv2_route" "create_order_lambda" {
  api_id    = aws_apigatewayv2_api.create_order.id
  route_key = "POST /api/v1/orders"
  target    = "integrations/${aws_apigatewayv2_integration.create_order_lambda.id}"
}

resource "aws_apigatewayv2_route" "migrate_db" {
  api_id    = aws_apigatewayv2_api.create_order.id
  route_key = "POST /api/v1/migrate"
  target    = "integrations/${aws_apigatewayv2_integration.create_order_lambda.id}"
}

// provide permission for API GW to invoke lambda function
resource "aws_lambda_permission" "create_order" {
  statement_id  = "api-gateway-app-order"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.create_order.execution_arn}/*/*"
}
