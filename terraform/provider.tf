# terraform {
#   backend "local" {}
# }

# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "ap-southeast-1"
#   shared_credentials_file = "~/.aws/rootkey.csv"
}