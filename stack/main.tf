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
  zone                    = "chunklight.com"
  cert_arn                = "arn:aws:acm:us-east-1:368746525003:certificate/3e477b43-2106-40bd-b068-167ed94384c2"
  environment             = local.environment
}
