# Get the latest Ubuntu 22.04 AMI automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (creators of Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. The Master Node
resource "aws_instance" "k8s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  key_name                    = "phoenix-k8s-key"
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name

  root_block_device {
    volume_size = 20 # GB
  }

  tags = {
    Name = "${var.project_name}-master"
    Role = "master"
  }
}

# 2. The Worker Nodes (We want 2 of them)
resource "aws_instance" "k8s_worker" {
  count         = 2                           # <-- MAGIC NUMBER: Creates 2 identical servers
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  key_name                    = "phoenix-k8s-key"
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name

  root_block_device {
    volume_size = 20 # GB
  }

  tags = {
    Name = "${var.project_name}-worker-${count.index + 1}"  # Names them worker-1, worker-2
    Role = "worker"
  }
}