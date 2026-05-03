terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "legal_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "legal-insight-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.legal_vpc.id
  tags   = { Name = "legal-insight-igw" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.legal_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "legal-private-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.legal_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "legal-private-2" }
}

resource "aws_security_group" "db_sg" {
  name        = "legal-db-sg"
  description = "Permite acesso ao Postgres e Redis"
  vpc_id      = aws_vpc.legal_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
