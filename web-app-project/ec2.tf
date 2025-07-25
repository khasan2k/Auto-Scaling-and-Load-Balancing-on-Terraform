data "aws_key_pair" "hasancse2020" {
  key_name = "hasancse2020"
}

# output "vpc_id" {
#     value = aws_vpc.this.id
# }

resource "aws_instance" "web-app-project" {
    instance_type = var.instance_type
    ami = var.ami_id
    key_name = data.aws_key_pair.hasancse2020.key_name
    associate_public_ip_address = true
    subnet_id = module.vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.web-app-project-sg.id]
    user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              echo "Hello from Terraform" > /var/www/html/index.html
              EOF
    tags = {
        Name = "${var.web_app_name}-instance"
    }          
}

#Create security Group
resource "aws_security_group" "web-app-project-sg" {
    name = "${var.web_app_name}-sg"
    vpc_id = module.vpc.vpc_id
  
    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "${var.web_app_name}-sg"
  }
}

#Create AMI image

resource "aws_ami_from_instance" "web_app_ami" {
    name               = "${var.web_app_name}-ami"
    source_instance_id = aws_instance.web-app-project.id

    tags = {
      Name = "${var.web_app_name}-hasan"
    }

    depends_on = [aws_instance.web-app-project]
}

#Create Launch Template

resource "aws_launch_template" "web_app_template" {
    name_prefix   = "${var.web_app_name}-lt"
    image_id      = aws_ami_from_instance.web_app_ami.id
    instance_type = var.instance_type
    key_name      = data.aws_key_pair.hasancse2020.key_name

    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [aws_security_group.web-app-project-sg.id]
    }

    user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              echo "Hello from Auto Scaling" > /var/www/html/index.html
              EOF
            )

    tags = {
        Name = "${var.web_app_name}-lt"
    }
}


#Setting Up Auto Scaling and Load Balancing

#Create New Target Group

resource "aws_lb_target_group" "web_app_tg" {
  name     = "${var.web_app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#Register Target Group

resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.web_app_tg.arn
  target_id        = aws_instance.web-app-project.id
  port             = 80
}

#Setting Up an Application Load Balancer (ALB)

#Create New Load Balancer

resource "aws_lb" "web_app_alb" {
  name               = "${var.web_app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-app-project-sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}

#Create Auto Scaling Group

resource "aws_autoscaling_group" "web_asg" {
  name                      = "${var.web_app_name}-asg"
  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  vpc_zone_identifier       = module.vpc.public_subnets
  target_group_arns         = [aws_lb_target_group.web_app_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  default_cooldown = 300

  launch_template {
    id      = aws_launch_template.web_app_template.id
    version = "$Default"
  }

  tag {
    key                 = "Name"
    value               = "${var.web_app_name}-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "web_app_cpu_target" {
  name                   = "cpu-utilization-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value       = 25.0  #Target CPU utilization in percent
    disable_scale_in   = false
  }
}





