terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "marom-eks-terraform-bucket-1"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
