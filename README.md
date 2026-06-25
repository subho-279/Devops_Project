# Devops_Project

A full AWS DevOps pipeline: **GitHub → CodePipeline → CodeBuild → EC2**, with Terraform IaC, Kubernetes manifests, Sealed Secrets, and a GitHub Actions fallback.

---

## Architecture

```
GitHub (main branch)
    └─► AWS CodePipeline
            ├─ Source  : CodeStar GitHub Connection
            ├─ Build   : CodeBuild (MyBuildProject) — npm install + build
            └─ Deploy  : CodeBuild (DeployToEC2)    — SCP + SSH
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.5 |
| AWS CLI | ≥ 2.x (authenticated) |
| Node.js | 18.x |
| kubectl | ≥ 1.28 (for k8s manifests) |
| kubeseal | ≥ 0.24 (for Sealed Secrets) |

---

## Secrets Setup (do this before `terraform apply`)

All secrets are stored in **AWS SSM Parameter Store** — nothing sensitive lives in this repo.

```bash
# Base64-encode your EC2 private key and store it in SSM
base64 < ~/.ssh/devops_key.pem | aws ssm put-parameter \
  --name /devops/ec2_ssh_key \
  --type SecureString \
  --value file:///dev/stdin

# Store your GitHub PAT
aws ssm put-parameter \
  --name /devops/github_token \
  --type SecureString \
  --value "ghp_YOUR_TOKEN_HERE"
```

---

## Deploy with Terraform

```bash
cd terraform/

# Create a terraform.tfvars (already in .gitignore — never commit it)
cat > terraform.tfvars <<TFVARS
artifact_bucket_name = "devops-artifacts-subho-prod"
logging_bucket_name  = "devops-logs-subho-prod"
TFVARS

terraform init
terraform plan
terraform apply
```

After apply, **activate the CodeStar connection** in the AWS Console:

> Developer Tools → Connections → `github-connection` → **Update pending connection**

---

## Kubernetes (local / EKS)

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get svc nginx-service
```

### Sealed Secrets

```bash
# Edit sealed-secrets/secret.yaml with your real value (do NOT commit it)
kubeseal --format yaml < sealed-secrets/secret.yaml > sealed-secrets/sealedsecret.yaml
kubectl apply -f sealed-secrets/sealedsecret.yaml
```

---

## GitHub Actions (alternative pipeline)

Set these in **Settings → Secrets and variables**:

| Secret | Description |
|--------|-------------|
| `EC2_SSH_KEY` | Base64-encoded EC2 private key |

| Variable | Description |
|----------|-------------|
| `EC2_IP` | Public IP of your EC2 instance |
| `EC2_SSH_USER` | SSH user (e.g. `ec2-user`) |

---

## Running Terratest

```bash
cd terraform/test/
go test -v -timeout 30m
```
