# High Availability (HA) Control Plane Proposal

## Current Setup Analysis

The current Kubernetes cluster, provisioned via Terraform and Ansible, utilizes a single master node (`aws_instance.k8s_master`). While this simplifies initial deployment, it represents a single point of failure for the Kubernetes control plane. If this master node experiences an outage (e.g., instance failure, network issues, software corruption), the entire cluster's API server, scheduler, and controller manager become unavailable, preventing any management operations (deploying new applications, scaling existing ones, performing rolling updates). Existing workloads may continue to run if their underlying worker nodes are healthy, but no new workloads can be scheduled, and recovery from failures becomes impossible until the master node is restored.

## Risks of Single Master Node

1.  **Single Point of Failure (SPOF):** Any issue with the master node leads to a complete loss of cluster management capabilities.
2.  **Downtime:** Restoring a failed master node can involve significant downtime.
3.  **Maintenance Windows:** Performing maintenance on the master node requires cluster downtime.
4.  **Data Loss (etcd):** While `kubeadm`'s default etcd configuration stores data on the master node's local disk, a complete disk failure can lead to data loss if backups are not consistently taken and recoverable.

## Proposed High Availability (HA) Architecture

To mitigate the risks associated with a single master node, a highly available control plane is recommended. The most common and recommended approach for `kubeadm`-based clusters is a **stacked etcd topology** with an external load balancer.

### Architecture Overview

This architecture involves:

1.  **Multiple Master Nodes:** Deploying three (or five, for larger clusters) master nodes instead of one. These nodes will run all control plane components (kube-apiserver, kube-scheduler, kube-controller-manager) and an embedded etcd instance.
2.  **External Load Balancer:** A dedicated external load balancer (e.g., AWS Network Load Balancer or Application Load Balancer) to distribute API requests across the multiple `kube-apiserver` instances running on each master node. This provides a stable endpoint for `kubectl` and worker nodes to communicate with the control plane.
3.  **Quorum for etcd:** With three master nodes, etcd will maintain a quorum, ensuring data consistency and availability even if one master node fails.

### Components Involved

*   **AWS EC2 Instances:** 3 x `t3.large` instances for master nodes.
*   **AWS Load Balancer:** An NLB or ALB to front the Kubernetes API servers.
*   **Terraform:** To provision the additional EC2 instances and the load balancer.
*   **Ansible:** To configure `kubeadm` for an HA setup, including:
    *   Initializing the first master node.
    *   Joining additional master nodes.
    *   Configuring `kube-apiserver` to listen on the load balancer IP.
    *   Setting up health checks for the load balancer targets.

### High-Level Steps for Implementation

1.  **Modify Terraform:**
    *   Update `compute.tf` to provision `count = 3` for `k8s_master` instances.
    *   Provision an AWS Load Balancer (NLB recommended for API server) and target groups.
    *   Configure security groups (`security.tf`) to allow traffic from the load balancer to the master nodes' API server port (6443).
    *   Add outputs for load balancer DNS name/IP.
2.  **Modify Ansible:**
    *   Adjust the `master` role to perform `kubeadm init` with `--control-plane-endpoint` pointing to the load balancer's DNS name/IP.
    *   Create a new Ansible task or role to run `kubeadm join --control-plane-endpoint ... --experimental-control-plane` on the additional master nodes.
    *   Ensure all necessary certificates and kubeconfig files are properly distributed.
3.  **Update CNI (if necessary):** Verify the chosen CNI (Flannel in this case) supports HA.
4.  **Testing:** Thoroughly test the HA setup by simulating master node failures.

## Impact on Project

Implementing HA for the Kubernetes control plane is a critical improvement for a production-ready system. It significantly enhances reliability, reduces downtime during failures or maintenance, and protects against data loss.

Given the scope and complexity, this could be treated as a dedicated follow-up project phase. The existing single-master setup, while not HA, is functional for development and testing purposes. However, for a "perfectly finished" production system as requested, HA is essential.

## Next Steps (Documentation Focus)

For the current project, the immediate next steps would be:

1.  Acknowledge the current single-master limitation.
2.  Ensure that the Terraform and Ansible setup for the single master is robust.
3.  Provide this proposal as a clear path for future enhancement.