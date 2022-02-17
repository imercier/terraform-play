data "aws_region" "current" {
  provider = aws.region
}

provider "aws" {
  alias = "region"
}
