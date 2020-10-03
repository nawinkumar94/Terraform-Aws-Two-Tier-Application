### Instances ###
resource "aws_instance" "instances" {
  ami           = lookup(var.AMIS,var.AWS_REGION)

  instance_type = var.INSTANCE_TYPE

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  subnet_id = var.SUBNET_PUBLIC_1

  key_name = aws_key_pair.mykey.key_name

  iam_instance_profile = aws_iam_instance_profile.s3-mybucket-role-instanceprofile.name

   #user_data = file("script.sh")
}

### Security Groups for instances ###
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh-${var.ENVIRONMENT}"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.VPC_ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.CIDR_BLOCK_0]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups  = [aws_security_group.load-balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CIDR_BLOCK_0]
  }

  tags = {
    Name = "allow_ssh-${var.ENVIRONMENT}"
    Environment = "${var.ENVIRONMENT}"
  }
}

### SSH Keypair ###
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("${path.root}/${var.PATH_TO_PUBLICKEY}")
}

### EBS Volume ###
resource "aws_ebs_volume" "new_volume" {
  availability_zone = "${var.AWS_REGION}a"
  size              = 20
  tags = {
    Name = "new_volume_EBS"
  }
}

### Additional EBS Volume Attachment ###
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.new_volume.id
  instance_id = aws_instance.instances.id
}

### Aws launch configuration for instances using auto scaling ###
resource "aws_launch_configuration" "autoscale_instances" {
  image_id           = lookup(var.AMIS,var.AWS_REGION)

  instance_type   = var.INSTANCE_TYPE

  #subnet_id       = var.SUBNET_PUBLIC_1

  security_groups  = [aws_security_group.allow_ssh.id]

  key_name        = aws_key_pair.mykey.key_name

  user_data       = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'this is: '$MYIP > /var/www/html/index.html"

  lifecycle {
      create_before_destroy = true
    }

}

### Autoscaling group ###
resource "aws_autoscaling_group" "auto_scale_grp" {
  name                      = "auto-scale-grp"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.elb.name]
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.autoscale_instances.name
  vpc_zone_identifier       = [var.SUBNET_PUBLIC_1, var.SUBNET_PUBLIC_2]

}

### Elastic Load Balancers ###
resource "aws_elb" "elb" {
  name               = "elb"
  subnets            = [var.SUBNET_PUBLIC_1, var.SUBNET_PUBLIC_2]
  security_groups    = [aws_security_group.load-balancer.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}

### Security group for load balancers ###
resource "aws_security_group" "load-balancer" {
  name        = "load-balancer"
  description = "Security group for load balancer"
  vpc_id      =  var.VPC_ID


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.CIDR_BLOCK_0]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CIDR_BLOCK_0]
  }

  tags = {
    Name = "load-balancer"
  }
}

### Subnet for maria_db ###
resource "aws_db_subnet_group" "maria_db_subnet" {
  name       = "maria_db_subnet"
  subnet_ids = [var.SUBNET_PUBLIC_1, var.SUBNET_PUBLIC_2]

  tags = {
    Name = "maria_db_subnet"
  }
}

### parameter group for maria_db ###
resource "aws_db_parameter_group" "maria_db_parameter" {
  name   = "mariadbparameter"
  family = "mariadb10.1"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}

### DB instances for maria DB ###
resource "aws_db_instance" "maria_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.1.14"
  instance_class       = var.INSTANCE_CLASS
  name                 = "mydb"
  username             = "root"
  password             = var.RDS_PASSWORD
  skip_final_snapshot  = "true"
  parameter_group_name = aws_db_parameter_group.maria_db_parameter.name
  db_subnet_group_name = aws_db_subnet_group.maria_db_subnet.name
  vpc_security_group_ids = [aws_security_group.allow_maria_db.id]
  multi_az = "false"
}

### Security group for maria_db ###
resource "aws_security_group" "allow_maria_db" {
  name        = "allow_maria_db"
  description = "Allow Maria DB"
  vpc_id      =  var.VPC_ID

  ingress {
    description = "mariadb from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CIDR_BLOCK_0]
  }

  tags = {
    Name = "allow_maria_db"
  }
}

### IAM role for s3 bucket ###
resource "aws_iam_role" "s3-mybucket-role" {
  name               = "s3-mybucket-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

### Instance profile for the role ###
resource "aws_iam_instance_profile" "s3-mybucket-role-instanceprofile" {
  name = "s3-mybucket-role"
  role = aws_iam_role.s3-mybucket-role.name
}

### Role policy for s3 bucket ###
resource "aws_iam_role_policy" "s3-mybucket-role-policy" {
  name = "s3-mybucket-role-policy"
  role = aws_iam_role.s3-mybucket-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::inventory-receipt-hue-011",
              "arn:aws:s3:::inventory-receipt-hue-011/*"
            ]
        }
    ]
}
EOF

}
