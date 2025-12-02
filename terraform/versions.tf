terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.114"   // current 3.x
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"    // current 5.x
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"    // current 5.x
    }
  }

  required_version = ">= 1.9.0"
}