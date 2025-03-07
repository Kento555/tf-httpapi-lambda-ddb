terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0" # Use the latest stable version
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}
