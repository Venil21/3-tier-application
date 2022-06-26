terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


module "networking"{
    source = "./networking"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.24.1"
  vpc_id = module.networking.vpc_id
  cluster_name    = "eks-cluster"
  cluster_version = "1.22"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  subnet_ids = module.networking.app_subnet_ids
  node_security_group_name = "eks_security_group"
    eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
   tags = {
    Environment = module.networking.environment
    Terraform   = "true"
  }
}

module "rds_cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  depends_on = [module.networking.rds_sg]
  name           = "aurora-db-postgres"
  engine         = "aurora-postgresql"
  engine_version = 13.1
  instance_class = "db.r6g.large"
  master_username = "admin"
  master_password = "admin"
  instances = {
    one = {}
    2 = {
      instance_class = "db.r6g.large"
    }
  }

  vpc_id  = module.networking.vpc_id
  subnets = module.networking.private_db_subnets



  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = module.networking.environment
    Terraform   = "true"
  }
}