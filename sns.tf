# Create SNS topic for Lambda notifications
resource "aws_sns_topic" "lambda_notification" {
  name = "lambda-notification-topic"
}

# Create an SNS topic subscription (email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.lambda_notification.arn
  protocol  = "email"
  endpoint  = "kentokongweishen@gmail.com"  # Replace with your email address
}

# Lambda permissions to publish to SNS
resource "aws_lambda_permission" "sns_publish" {
  statement_id  = "AllowSNSPublish"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_api_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_notification.arn
}