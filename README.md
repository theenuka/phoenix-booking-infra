# Phoenix Booking - Infrastructure Repository

This repository contains the Infrastructure as Code (IaC) for provisioning the Kubernetes cluster for the Phoenix Booking system. It uses Terraform to provision the necessary AWS resources (EC2 instances, VPC, security groups) and Ansible to configure these instances, including setting up a `kubeadm`-based Kubernetes cluster.

## Structure

*   **`terraform/`**: Contains Terraform configurations for provisioning AWS infrastructure.
    *   `backend.tf`: Defines Terraform remote backend (S3).
    *   `compute.tf`: Provisions EC2 instances for Kubernetes master, workers, and a bastion host.
    *   `iam.tf`: Configures AWS IAM roles and policies.
    *   `outputs.tf`: Defines Terraform output variables.
    *   `provider.tf`: Configures the AWS provider.
    *   `security.tf`: Manages AWS security groups.
    *   `variables.tf`: Declares input variables for Terraform.
    *   `vpc.tf`: Sets up the VPC and networking.
*   **`ansible/`**: Contains Ansible playbooks and roles for configuring the provisioned EC2 instances.
    *   `aws_ec2.yml`: Dynamic inventory file for discovering EC2 instances based on tags.
    *   `site.yaml`: Main playbook orchestrating the setup of common packages, Kubernetes master, workers, and ArgoCD.
    *   `roles/`: Individual Ansible roles (e.g., `common`, `master`, `workers`, `argocd`).
*   **`k8s/`**: Contains Kubernetes manifests used by Ansible roles (e.g., Flannel CNI, ArgoCD installation).

## Usage

### Prerequisites

*   AWS Account with configured credentials.
*   Terraform installed locally.
*   Ansible installed locally.
*   `kubectl` installed locally.

### Provisioning Infrastructure

1.  **Initialize Terraform**:
    ```bash
    cd terraform
    terraform init
    ```
2.  **Review Plan**:
    ```bash
    terraform plan
    ```
3.  **Apply Changes**:
    ```bash
    terraform apply
    ```
    This will provision the EC2 instances. Ensure the `Role` tags are correctly applied to the master and worker instances.

### Configuring Kubernetes with Ansible

1.  **Navigate to Ansible Directory**:
    ```bash
    cd ansible
    ```
2.  **Run Ansible Playbook**:
    ```bash
    ansible-playbook -i aws_ec2.yml site.yaml
    ```
    This will configure the EC2 instances, set up the Kubernetes cluster using `kubeadm`, and install ArgoCD with its Image Updater.

## Important Notes

*   **Security**: Ensure your SSH key (`~/.ssh/phoenix-k8s-key.pem` as configured in `aws_ec2.yml`) has appropriate permissions and is secured.
*   **ArgoCD**: After provisioning, access ArgoCD using the configured ingress hostname. The initial password can be retrieved from the `argocd-initial-admin-secret` in the `argocd` namespace.
*   **kubectl access**: Copy the `admin.conf` from the master node to your local machine (`~/.kube/config`) to access the cluster using `kubectl`.

This `README.md` provides an overview. Refer to the specific Terraform and Ansible files for detailed configurations.
