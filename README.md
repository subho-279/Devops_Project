# DevOps Project

> End-to-end AWS CI/CD pipeline with Terraform IaC, Kubernetes, Sealed Secrets, and GitHub Actions.

---

## Project Structure

```
Devops_Project/
├── .github/workflows/
│   ├── main.yml               # DevSecOps pipeline (security scan + K8s deploy)
│   └── ci-cd-pipeline.yml     # Build & deploy to EC2 via GitHub Actions
├── terraform/
│   ├── main.tf                # CodePipeline, CodeBuild, S3, IAM
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf             # Remote state (S3 + DynamoDB)
│   ├── buildspec.yml
│   └── deploy/buildspec.yml
│   └── test/
│       └── test_pipeline_test.go  # Terratest integration tests
├── docker/
│   └── Dockerfile             # Node.js 18 app image
├── k8s/
│   └── deployment.yaml        # Nginx Deployment + ClusterIP Service
├── sealed-secrets/
│   ├── secret.yaml            # Local-only template (never commit real values)
│   └── sealedsecret.yaml      # Encrypted — safe to commit
├── deploy/
│   └── buildspec.yml          # CodeBuild EC2 deploy phase
└── buildspec.yml              # CodeBuild build phase
```

---

## Architecture

```
GitHub (main branch)
    └─► AWS CodePipeline
            ├─ Source  : CodeStar GitHub Connection
            ├─ Build   : CodeBuild → npm install + build
            └─ Deploy  : CodeBuild → SCP + SSH to EC2
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.5 |
| AWS CLI | ≥ 2.x (authenticated) |
| Node.js | 18.x |
| kubectl | ≥ 1.28 |
| kubeseal | ≥ 0.24 |

---

## Setup

### 1. Store secrets in AWS SSM Parameter Store

> Nothing sensitive is stored in this repo. All secrets are pulled from SSM at runtime.

```bash
# EC2 private key (base64-encoded)
base64 < ~/.ssh/devops_key.pem | aws ssm put-parameter \
  --name /devops/ec2_ssh_key \
  --type SecureString \
  --value file:///dev/stdin

# GitHub Personal Access Token
aws ssm put-parameter \
  --name /devops/github_token \
  --type SecureString \
  --value "ghp_YOUR_TOKEN_HERE"
```

### 2. Deploy infrastructure with Terraform

```bash
cd terraform/

# Create terraform.tfvars — this file is gitignored, never commit it
cat > terraform.tfvars <<TFVARS
artifact_bucket_name = "devops-artifacts-subho-prod"
logging_bucket_name  = "devops-logs-subho-prod"
TFVARS

terraform init
terraform plan
terraform apply
```

After `apply`, activate the GitHub connection in the AWS Console:

**Developer Tools → Connections → `github-connection` → Update pending connection**

### 3. Deploy to Kubernetes

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get svc nginx-service
```

**Sealed Secrets:**

```bash
# Fill in sealed-secrets/secret.yaml locally (do NOT commit real values)
kubeseal --format yaml < sealed-secrets/secret.yaml > sealed-secrets/sealedsecret.yaml
kubectl apply -f sealed-secrets/sealedsecret.yaml
```

### 4. GitHub Actions setup

Add the following in **Settings → Secrets and variables**:

| Type | Name | Description |
|------|------|-------------|
| Secret | `EC2_SSH_KEY` | Base64-encoded EC2 private key |
| Secret | `KUBE_CONFIG_DATA` | Base64-encoded kubeconfig |
| Secret | `MINIKUBE_CLIENT_CRT` | Base64-encoded client certificate |
| Secret | `MINIKUBE_CLIENT_KEY` | Base64-encoded client key |
| Secret | `MINIKUBE_CA_CRT` | Base64-encoded CA certificate |
| Secret | `SEALED_CERT` | Base64-encoded sealed-secrets controller cert |
| Secret | `SECRET_PASSWORD` | The actual secret value to seal |
| Variable | `EC2_IP` | Public IP of your EC2 instance |
| Variable | `EC2_SSH_USER` | SSH user (e.g. `ec2-user`) |

### 5. Run Terratest

```bash
cd terraform/test/
go test -v -timeout 30m
```

---

## Security notes

- Private keys, kubeconfigs, and `.pem` files are listed in `.gitignore` and must never be committed
- All runtime secrets are injected via AWS SSM Parameter Store (type `SecureString`)
- Docker image runs as a non-root user
- Trivy and tfsec scans run on every push via GitHub Actions
