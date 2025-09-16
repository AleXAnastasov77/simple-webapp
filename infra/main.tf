resource "aws_servicecatalogappregistry_application" "marketing_web_app" {
  provider    = aws.application
  name        = "CS1WebApp"
  description = "Case Study 1 Web application"
}

provider "aws" {
  default_tags {
    tags = merge(
      var.tags,
      aws_servicecatalogappregistry_application.marketing_web_app.application_tag
    )
  }
}