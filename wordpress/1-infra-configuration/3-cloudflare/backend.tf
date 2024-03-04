terraform {
  backend "s3" {
    bucket = "lexd-solutions-tfstate"
    key    = "terraform/cloudflare.tfstate"
    region = "ap-southeast-2"
  }
}
