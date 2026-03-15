data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------
# IAM Role לכל ה-EC2 instances
# -----------------------------
resource "aws_iam_role" "app" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.app.name
}

locals {
  ecr_registry = split("/", var.client_repository_url)[0]
}

# ==============================
# CLIENT
# ==============================

resource "aws_launch_template" "client" {
  name_prefix   = "${var.project_name}-lt-client-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data_client.sh", {
    region       = var.aws_region
    ecr_registry = local.ecr_registry
    client_image = "${var.client_repository_url}:${var.image_tag}"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-client"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "client" {
  name                = "${var.project_name}-client-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.client_tg_arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.client.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-client-asg"
    propagate_at_launch = false
  }
}

# ==============================
# SERVER
# ==============================

resource "aws_launch_template" "server" {
  name_prefix   = "${var.project_name}-lt-server-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data_server.sh", {
    region       = var.aws_region
    ecr_registry = local.ecr_registry
    server_image = "${var.server_repository_url}:${var.image_tag}"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "server" {
  name                = "${var.project_name}-server-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.server_tg_arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-server-asg"
    propagate_at_launch = false
  }
}
