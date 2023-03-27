locals {
    vpc_id = "your_vpc_id"
    subnet_id1 = "your_subnetid1"
    subnet_id2 = "yout_subnet_id2"
    ssh_user = "ubuntu"
    key_name ="prv-key"
    private_key_path = "path/to/key/prv-key.pem"
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
  access_key = "your_access"
  secret_key = "your_secret"
}

resource "aws_security_group" "nginx" {
    name = "nginx_access"
    vpc_id = local.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


# Create an EC2 instance
resource "aws_instance" "nginx" {
  ami = "ami-0557a15b87f6559cf"
  subnet_id = local.subnet_id1
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = local.key_name
  security_groups = [aws_security_group.nginx.id]

provisioner "remote-exec" {
        inline = ["echo 'Wait until SSH is ready'"]

        connection {
            type = "ssh"
            user = local.ssh_user
            private_key = file(local.private_key_path)
            host = aws_instance.nginx.public_ip
        }
    }
provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} playbook.yml"
    }
}

#Create S3 Bucket

resource "aws_s3_bucket" "terrabucket" {
    bucket = "terraform_bucket"
    force_destroy = true

    tags = {
        Name        = "My bucket"
        Environment = "Dev"
  } 
}    
resource "aws_s3_bucket_server_side_encryption_configuration" "example"{ #By default it is off, so providing
    bucket = aws_s3_bucket.b.bucket  
    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
}

data "aws_vpc" "default_vpc" {
    default = true
}

#Setup Load Balancer


#Define load balancer target group
resource "aws_lb_target_group" "instances" {
    name = "my-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = data.aws_vpc.default_vpc.id
}

#Define load balancer target group attachment
resource "aws_lb_target_group_attachment" "nginx" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.nginx.id
    port = 80
}

#Define listener where default action is to forward traffic to target group
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port = 80
    protocol ="HTTP"

    default_action {
        target_group_arn = aws_lb_target_group.instances.arn
        type = "forward"
    }
}

resource "aws_lb" "load_balancer" {
    name = "my-load-balancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.nginx.id]
    subnets = [local.subnet_id1, local.subnet_id2]

    tags = {
        Name = "my-load-balancer"
    }
}

# Define the Ansible playbook
data "template_file" "playbook" {
  template = file("playbook.yml")
  vars = {
    django_secret_key = "mysecretkey"
    db_name = "mydb"
    db_user = "myuser"
    db_password = "mypassword"
    allowed_hosts = aws_instance.nginx.public_ip
    static_root = "/var/www/myapp/static"
  }
}


# Output the public IP address of the instance
output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}

output "nginx_port" {
  value = "80"
}

output "django_ip" {
  value = aws_instance.nginx.public_ip
}

output "django_port" {
  value = "8000"
}
