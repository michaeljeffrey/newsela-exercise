terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.4.0"
    }
  }
}

provider "aws" {
	region  = var.region
}

locals {
	environment = terraform.workspace
}

module "website" {
  source                  = "./modules/website/"
  base_website_name       = "newsela-exercise"
  zone                    = "newsela.com"
  cert_arn                = "CERT_ARN_HERE"
  environment             = local.environment
}
