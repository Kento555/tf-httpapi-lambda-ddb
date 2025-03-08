# Create SNS topic for Lambda notifications
resource "aws_sns_topic" "lambda_notification" {
  name = "${local.name_prefix}-lambda-notification-topic"
}

# Create an SNS topic subscription (email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.lambda_notification.arn
  protocol  = "email"
  endpoint  = "kentokongweishen@gmail.com"  # Replace with your email address
}

resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "${local.name_prefix}-LambdaSNSPublishPolicy"
  description = "Allow Lambda to publish to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.lambda_notification.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

