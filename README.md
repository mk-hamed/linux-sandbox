# Linux Sandbox

Linux Sandbox is a cloud-native application hosting an Ubuntu environment right in the browser. Any user can visit linuxsandbox.dev and start practicing Linux commands. 

Built on AWS EKS, provisioned with Terraform, and deployed via a GitHub Actions CI/CD pipeline. The cluster is currently spun down to manage costs — screenshots below.

## 📃 About

This project started because I wanted to learn some industry relevant skills for DevOps, Platform Engineering, and SRE. The idea was inspired by services such as VirtualBox and LabEx. However, the primary difference is that both of those applications run on virtual machines, whereas linux sandbox runs on containers. This is due to the prevalence of Docker and Kubernetes in DevOps, spinning up virtual machines isn't very relevant. In this project I've provisioned AWS resources such as EKS and ECR through terraform, built container images with Docker, and automated workflows using GitHub Actions. 

## 🔌 Technologies 
- AWS (EKS, ECR, Route53, EC2, VPC, ACM)
- Terraform
- Kubernetes
- Docker
- Ubuntu 22.04
- NGINX
- GitHub Actions
- ttyd
- Helm

## 📷 Screenshots

Landing Page

![Landing Page](screenshots/landing1.png)
![Landing Page](screenshots/landing2.png)

Terminal

![Terminal](screenshots/terminal2.png)

## ❓ How it Works

The sandbox utilizes a custom Ubuntu Docker image which lives in the AWS Elastic Container Registry. An AWS Virtual Private Cloud runs EKS which is configured to pull the Docker images from an ECR repository. An NGINX Ingress controller is used to route traffic (HTTP/HTTPS) to the cluster. Cert-manager then handles the SSL certificate for the domain, and Route53 points the domain to the load balancer. Finally GitHub Actions has docker and terraform CI/CD pipelines to automate image build/push, credential authentication, and terraform apply. When a user clicks "Launch Terminal", they get their own pod running Ubuntu on the EKS cluster.

## 💻 Architecture 
![Diagram](screenshots/diagram.png)
