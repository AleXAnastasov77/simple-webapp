resource "aws_servicecatalogappregistry_application" "marketing_web_app" {
  provider    = aws.application
  name        = "CS1WebApp"
  description = "Case Study 1 Web application"
}