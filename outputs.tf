output "sqs_queue_url" {
  value       = aws_sqs_queue.process_order_queue.url
  description = "SQS queue URL"
}

output "apigw_endpoint" {
  value = aws_apigatewayv2_api.create_order.api_endpoint
}
