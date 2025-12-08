data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lbc_policy" {
  name        = "${var.project_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy      = data.http.iam_policy.response_body
}

resource "aws_iam_role" "k8s_node_role" {
  name = "${var.project_name}-k8s-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lbc_attach" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = aws_iam_policy.lbc_policy.arn
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_poweruser_attach" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "k8s_profile" {
  name = "${var.project_name}-k8s-profile"
  role = aws_iam_role.k8s_node_role.name
}
