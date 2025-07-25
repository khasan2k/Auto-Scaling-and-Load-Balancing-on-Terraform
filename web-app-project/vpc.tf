module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.web_app_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Environment = var.env
  }
}