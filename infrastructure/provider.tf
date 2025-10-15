terraform {
  backend "s3" {
    bucket = "arize-notes-tf-state-management"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }

}

provider "aws" {
  region = var.region
}
