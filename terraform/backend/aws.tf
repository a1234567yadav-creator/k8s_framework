terraform {
  backend "s3" {
    bucket         = "<your-s3-bucket>"
    key            = "state/dev-eks.tfstate"
    region         = "<your-region>"
    dynamodb_table = "<your-dynamodb-table>"
    encrypt        = true
  }
}
