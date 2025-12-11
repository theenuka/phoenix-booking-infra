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
    *   `site.yaml`: Main playbook orchestrating the setup of common packages, Kubernetes master, and workers.
    *   `roles/`: Individual Ansible roles (e.g., `common`, `master`, `workers`).
*   **`k8s/`**: Contains Kubernetes manifests used by Ansible roles (e.g., Flannel CNI).
*   **`docs/`**: Contains architecture and design documents.
    *   `HA_PROPOSAL.md`: A proposal for a High-Availability Kubernetes control plane.

## Usage

### Prerequisites

*   AWS Account with configured credentials.
*   Terraform installed locally.
*   Ansible installed locally.
*   `kubectl` installed locally.

### 1. Provisioning Infrastructure with Terraform

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

### 2. Configuring Kubernetes with Ansible

1.  **Navigate to Ansible Directory**:
    ```bash
    cd ansible
    ```
2.  **Run Ansible Playbook**:
    ```bash
    ansible-playbook -i aws_ec2.yml site.yaml
    ```
    This will configure the EC2 instances and set up the Kubernetes cluster using `kubeadm`.

### 3. Bootstrapping the Cluster with ArgoCD (GitOps)

After the Kubernetes cluster is up and running, the final step is to bootstrap it with ArgoCD and deploy the applications using a GitOps approach.

1.  **Install ArgoCD:**
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
2.  **Apply the Root App:**
    Clone the `pheonix-booking-config-repo` repository and apply the `root-app.yaml`:
    ```bash
    git clone https://github.com/theenuka/pheonix-booking-config-repo.git
    kubectl apply -f pheonix-booking-config-repo/root-app.yaml
    ```
    This will instruct ArgoCD to deploy all the platform services and applications defined in the `pheonix-booking-config-repo`.

## Important Notes

*   **Security**: Ensure your SSH key has appropriate permissions and is secured.
*   **ArgoCD Access**: After provisioning, access ArgoCD using the configured ingress hostname. The initial password can be retrieved from the `argocd-initial-admin-secret` in the `argocd` namespace.
*   **kubectl Access**: Copy the `admin.conf` from the master node to your local machine (`~/.kube/config`) to access the cluster using `kubectl`.
*   **High Availability**: The current setup uses a single master node. For production use, a high-availability control plane is recommended. See `docs/HA_PROPOSAL.md` for more details.

This `README.md` provides an overview. Refer to the specific Terraform and Ansible files for detailed configurations.
