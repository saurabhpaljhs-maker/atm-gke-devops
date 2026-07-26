# ATM-Project — GCP/GKE Version

Original ATM-Project (AWS/EKS) ko GCP/GKE pe migrate kiya gaya hai. Same app (Node.js + Express banking gateway), naya infra: Terraform → GKE Autopilot, Artifact Registry, Helm, ArgoCD (GitOps).

## Folder Structure

```
atm-gcp/
├── server.js, package.json, Dockerfile   # app - koi change nahi
├── Jenkinsfile                            # CI - Artifact Registry + Trivy + GitOps commit
├── terraform/
│   ├── provider.tf         # GCP provider + GCS remote state
│   ├── variables.tf
│   ├── gke.tf               # GKE Autopilot cluster
│   ├── artifact_registry.tf
│   └── bootstrap.sh         # pehle isko run karo
├── helm/atm-project/        # Helm chart (deploy.yaml ka replacement)
└── argocd/application.yaml  # GitOps deploy manifest
```

## Step-by-Step (Cloud Shell mein karna hai)

### 1. Repo push karo GitHub pe
```bash
git clone https://github.com/saurabhpaljhs-maker/ATM-Project.git
cd ATM-Project
# yahan is folder ka saara content copy/replace karo, phir:
git add .
git commit -m "feat: migrate infra to GCP/GKE with Terraform, Helm, ArgoCD"
git push origin main
```

### 2. Cloud Shell open karo (console.cloud.google.com > terminal icon)
```bash
gcloud config set project YOUR_PROJECT_ID
cd terraform
chmod +x bootstrap.sh
./bootstrap.sh
```

### 3. Terraform se GKE cluster + Artifact Registry banao
```bash
terraform init
terraform plan -var="project_id=YOUR_PROJECT_ID"
terraform apply -var="project_id=YOUR_PROJECT_ID"
# ~7-8 min lagega Autopilot cluster banne mein
```

### 4. kubectl ko cluster se connect karo
```bash
gcloud container clusters get-credentials atm-gke-cluster --region asia-south1 --project YOUR_PROJECT_ID
kubectl get nodes
```

### 5. Docker image build + push (manually test karne ke liye, Jenkins baad mein automate karega)
```bash
cd ..
gcloud auth configure-docker asia-south1-docker.pkg.dev
docker build -t asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/atm-project-repo/atm-project-app:v1 .
docker push asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/atm-project-repo/atm-project-app:v1
```

### 6. Helm values.yaml mein apna project ID + image tag update karo
`helm/atm-project/values.yaml` mein `PROJECT_ID` ko apne actual GCP project ID se replace karo.

### 7. ArgoCD install karo GKE cluster mein
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD UI access karne ke liye port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 8. ArgoCD Application apply karo (GitOps deploy trigger hoga)
```bash
kubectl apply -f argocd/application.yaml
```

### 9. Verify karo
```bash
kubectl get pods
kubectl get svc ramji-atm-service  # LoadBalancer IP milega yahan, thoda time lagega assign hone mein
```

Health check test karo: `curl http://<EXTERNAL-IP>/api/atm/health`

### 10. Kaam khatam hone pe cluster delete karo (billing bachane ke liye)
```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

## Interview Talking Points

- **Multi-cloud experience**: same app pipeline pattern EKS se GKE pe migrate kiya — AWS EKS module → GKE Autopilot, DockerHub → Artifact Registry
- **GitOps separation**: Jenkins sirf CI (build, scan, push, tag-commit) karta hai; ArgoCD deployment (CD) handle karta hai
- **Helm for environment consistency**: raw manifests ki jagah parametrized chart, dev/staging/prod mein reuse ho sakta hai
- **Security**: Trivy scan pipeline mein gate ki tarah, non-root container user, no hardcoded secrets (Jenkins credentials store se aate hain)
