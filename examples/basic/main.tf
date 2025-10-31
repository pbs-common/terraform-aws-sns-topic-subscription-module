module "topic" {
  source = "github.com/pbs/terraform-aws-sns-topic-module?ref=1.0.0"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
  owner        = var.owner
}

module "lambda" {
  source = "github.com/pbs/terraform-aws-lambda-module?ref=2.0.0"

  handler  = "main.lambda_handler"
  filename = "./artifacts/deploy.zip"
  runtime  = "python3.13"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo
  owner        = var.owner
}

module "lambda_permission" {
  source = "github.com/pbs/terraform-aws-lambda-permission-module?ref=1.0.0"

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.name
  principal     = "sns.amazonaws.com"
  source_arn    = module.topic.arn
}

module "subscription" {
  source = "../.."

  topic_arn = module.topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}
