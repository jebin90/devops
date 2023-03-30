#Demo file to test around concepts of terraform state and its remote storage in S3

provider "aws" {
  region     = "us-east-1"
  access_key = "your_access"
  secret_key = "your_secret"
}

resource "aws_instance" "us-east1" {
  ami           = "ami-02f3f602d23f1659d" # us-east-1
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state"
 
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning. Every update to a file in the bucket creates a new version of it. 
# Allows to revert to older versions if something goes wrong
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#DynamoDB table for locking with Terraform, with a primary key named LockID
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#---------------------------------
#Run terraform init before this 
#State is generated locally, but s3 and dynamodb are created on AWS

#Configures Terraform to store the state in your S3 bucket (with encryption and locking)
#Note that variables and references dont work in this, mention directly
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

#Now run Terraform init again, so the state is uploaded to s3
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}

#Now run terraform apply to complete the process

#To reverse all of this, remove backend config and run terraform init. This copies terraform state back to local
#Then run terraform destroy s3 and dynamodb
