data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_profile.name

  tags = {
    Name = "phoenix-bastion"
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.k8s_node_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_profile.name

  tags = {
    Name                                          = "phoenix-k8s-master"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    Role                                          = "master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = module.vpc.private_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.k8s_node_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_profile.name

  tags = {
    Name                                          = "phoenix-k8s-worker-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    Role                                          = "worker"
  }
}
