    provider "aws" {
        region = "us-east-2"
}

/*
    resource "aws_instance" "warmup" {
        ami     = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        vpc_security_group_ids = [aws_security_group.instance.id]

        user_data = <<-EOF
                    #!/bin/bash
                    echo "Hello, World" > index.html
                    nohup busybox httpd -f -p ${var.server_port} &
                    EOF

        tags = {
        Name = "warmup_instance"
    }

}

    variable "server_port" {
        description = "The port the server will use for HTTP requests"
        type = number
        default = 8080
    }

    resource "aws_security_group" "instance" {
        name = "terraform-warmup-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

    output "public_ip" {
      value = aws_instance.warmup.public_ip
      description = "The public IP address of the web server"
    }

*/

# Auto Scaling Group 

    resource "aws_launch_configuration" "warmup" {
      image_id = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
      security_groups = [aws_security_group.instance.id]

      user_data = <<-EOF
                    #!/bin/bash
                    echo "Hello, World" > index.html
                    nohup busybox httpd -f -p ${var.server_port} & 
                    EOF

    # Required when using a launch configuration with an auto scaling group.
    # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html

    lifecycle {
        create_before_destroy = true
    }
}

     variable "server_port" {
        description = "The port the server will use for HTTP requests"
        type = number
        default = 8080
}

    resource "aws_autoscaling_group" "warmup-asg" {
      launch_configuration = aws_launch_configuration.warmup-asg.name
      vpc_zone_identifier = data.aws_subnet_ids.default.ids

      min_size = 2
      max_size = 10

      tag {
        key = "Name"
        value = "terraform-asg-warmup-asg"
        propagate_at_launch = true
      }
}

    data "aws_vpc" "default" {
      default = true
}

    data "aws_subnet_ids" "default" {
        vpc_id = data.aws_vpc.default.id 
}