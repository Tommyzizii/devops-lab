# DevOps Lab — CI/CD Pipeline for Containerized Deployment on AWS EC2

[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=githubactions)](.github/workflows/deploy.yml)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker)](https://hub.docker.com/r/tommyzizii/devops-lab)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](terraform/)
[![AWS](https://img.shields.io/badge/Cloud-AWS%20EC2-FF9900?logo=amazonaws)](terraform/)
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen)]()

An automated deployment pipeline that provisions AWS infrastructure with Terraform, containerizes a web application with Docker, and deploys it through a GitHub Actions CI/CD workflow. Every push to `main` triggers a fully automated build-and-deploy cycle with no manual intervention.

## Summary

- Provisioned AWS EC2 infrastructure using Terraform (IaC), including security groups and automated instance bootstrapping via `user_data`
- Containerized a web application with Docker and published the image to Docker Hub
- Built a GitHub Actions CI/CD pipeline that builds, pushes, and deploys the container to EC2 on every commit to `main`
- Diagnosed and resolved a cross-architecture build failure (ARM64 vs AMD64) and a malformed SSH credential in the deployment pipeline
- Delivered a fully automated deployment loop — `git push` to live production update — with no manual server access required

## Tech Stack

| Category | Technology |
|---|---|
| Cloud | AWS EC2 |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Registry | Docker Hub |
| CI/CD | GitHub Actions |
| Operating System | Amazon Linux 2023 |
| Web Server | Nginx |
| Version Control | Git & GitHub |

## Architecture

```
Developer
   │
   ▼
Git Push
   │
   ▼
GitHub
   │
   ▼
GitHub Actions
   │
   ├── Build Docker Image
   ├── Push to Docker Hub
   └── SSH into EC2
             │
             ▼
     Pull Latest Image
             │
             ▼
     Restart Docker Container
             │
             ▼
     Updated Website Live
```

## Project Structure

```
devops-lab/
│
├── app/
│     ├── Dockerfile
│     └── index.html
│
├── terraform/
│     ├── main.tf
│     ├── providers.tf
│     ├── variables.tf
│     ├── outputs.tf
│     └── terraform.tfvars
│
└── .github/
      └── workflows/
            deploy.yml
```

---

## Implementation

### Phase 1 — Containerization (Docker)
```bash
docker build -t devops-lab .
docker tag devops-lab tommyzizii/devops-lab:v1
docker login
docker push tommyzizii/devops-lab:v1
```

### Phase 2 — Infrastructure Provisioning (Terraform)
Terraform provisions the EC2 instance, security group, and bootstraps Docker via a `user_data` script on first boot.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

**`user_data` bootstrap script:**
```bash
#!/bin/bash
dnf update -y
dnf install docker -y
systemctl enable docker
systemctl start docker
docker pull tommyzizii/devops-lab:v1
docker run -d \
  --name devops-container \
  -p 80:80 \
  tommyzizii/devops-lab:v1
```

### Phase 3 — Deployment Verification
```bash
ssh -i ~/.ssh/devops-key.pem ec2-user@PUBLIC_IP
sudo systemctl status docker
sudo docker ps
```

### Phase 4 — CI/CD Automation (GitHub Actions)
On every push to `main`, the workflow:
1. Builds the Docker image
2. Pushes it to Docker Hub
3. SSHes into the EC2 instance
4. Pulls the latest image
5. Stops the old container and starts the new one

**Required GitHub Secrets:**
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `EC2_HOST`
- `EC2_SSH_KEY`

### Infrastructure Teardown
```bash
terraform destroy
```

---

## Technical Challenges & Resolutions

| Issue | Root Cause | Resolution |
|---|---|---|
| Container exited immediately; `exec format error` in logs | Image was built on Apple Silicon (ARM64); EC2 `t3.micro` runs AMD64 (x86_64) — architecture mismatch | Rebuilt and pushed the image with `docker buildx build --platform linux/amd64`, then re-pulled and restarted the container on EC2 |
| GitHub Actions pipeline failed with `ssh: no key found` | `EC2_SSH_KEY` secret contained only the key body, missing the required `BEGIN`/`END` header and footer lines | Replaced the secret with the complete, unmodified `.pem` file contents |

Diagnosis in both cases followed the same process: reproduce via SSH, check service status, inspect container state (`docker ps -a`), and read container logs (`docker logs`) to isolate the root cause before applying a fix.

## Skills Demonstrated

- **Containerization:** Docker image builds, tagging, registries, and multi-platform builds
- **Infrastructure as Code:** Terraform providers, resources, variables, outputs, and data sources
- **Cloud infrastructure:** AWS EC2 provisioning, security groups, `user_data` bootstrapping
- **CI/CD:** GitHub Actions workflows, secrets management, automated build-and-deploy pipelines
- **Systems administration:** SSH-based deployment, Linux service management
- **Troubleshooting:** Root-cause diagnosis of cross-platform and credential-configuration failures
- **Infrastructure lifecycle management:** provision → deploy → verify → teardown

## Project Timeline

Completed: June 2026
