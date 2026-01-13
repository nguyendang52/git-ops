# GitOps Demo App - ArgoCD Setup Guide

This repository contains a Node.js application configured for GitOps deployment using ArgoCD and Kustomize.

## 📁 Project Structure

```
.
├── argocd/
│   ├── applications/           # ArgoCD Application manifests
│   │   ├── dev-application.yaml
│   │   └── prod-application.yaml
│   ├── projects/              # ArgoCD Project definitions
│   │   └── gitops-demo-project.yaml
│   └── README.md
├── k8s/
│   ├── base/                  # Base Kustomize manifests
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── overlays/              # Environment-specific overlays
│       ├── dev/
│       │   ├── kustomization.yaml
│       │   └── namespace.yaml
│       └── prod/
│           ├── kustomization.yaml
│           └── namespace.yaml
├── Dockerfile
├── server.js
└── package.json
```

## 🚀 Quick Start with ArgoCD

### Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- ArgoCD installed (see below)

### Step 1: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### Step 2: Access ArgoCD UI

```bash
# Port-forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Open https://localhost:8080 in your browser
- Username: `admin`
- Password: (from command above)

### Step 3: Deploy Your Application

#### Option A: Using kubectl (GitOps Way)

```bash
# Push these manifests to your Git repository first
git add argocd/ k8s/
git commit -m "Add ArgoCD and Kustomize configurations"
git push origin main

# Then apply the ArgoCD applications
kubectl apply -f argocd/applications/dev-application.yaml
kubectl apply -f argocd/applications/prod-application.yaml
```

#### Option B: Using ArgoCD CLI

```bash
# Install ArgoCD CLI (macOS)
brew install argocd

# Or download from https://github.com/argoproj/argo-cd/releases

# Login
argocd login localhost:8080 --insecure

# Create applications
argocd app create -f argocd/applications/dev-application.yaml
argocd app create -f argocd/applications/prod-application.yaml
```

### Step 4: Verify Deployment

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check application pods
kubectl get pods -n gitops-demo-dev
kubectl get pods -n gitops-demo-prod

# Check services
kubectl get svc -n gitops-demo-dev
kubectl get svc -n gitops-demo-prod
```

### Step 5: Test the Application

```bash
# Port-forward the dev service
kubectl port-forward -n gitops-demo-dev svc/dev-gitops-demo-app 3000:80

# In another terminal, test the endpoint
curl http://localhost:3000
curl http://localhost:3000/health
```

## 🔄 GitOps Workflow

1. **Make changes** to your code or Kubernetes manifests
2. **Commit and push** to the main branch
3. **ArgoCD automatically detects** changes (within 3 minutes by default)
4. **Auto-sync deploys** changes to the cluster
5. **Monitor** in ArgoCD UI

## 📊 Environment Differences

| Feature | Development | Production |
|---------|------------|------------|
| Namespace | gitops-demo-dev | gitops-demo-prod |
| Replicas | 1 | 3 |
| CPU Request | 100m | 200m |
| CPU Limit | 200m | 500m |
| NODE_ENV | development | production |

## 🛠️ Common Operations

### Manual Sync

```bash
argocd app sync gitops-demo-app-dev
argocd app sync gitops-demo-app-prod
```

### View Application Status

```bash
argocd app get gitops-demo-app-dev
argocd app list
```

### View Logs

```bash
argocd app logs gitops-demo-app-dev
kubectl logs -n gitops-demo-dev -l app=gitops-demo-app -f
```

### Rollback

```bash
# View history
argocd app history gitops-demo-app-dev

# Rollback to specific revision
argocd app rollback gitops-demo-app-dev <revision-number>
```

### Delete Application

```bash
# Delete from cluster (keeps ArgoCD app definition)
argocd app delete gitops-demo-app-dev --cascade=false

# Delete everything including ArgoCD app
argocd app delete gitops-demo-app-dev
```

## 🔧 Customization

### Update Repository URL

Edit the `repoURL` in:
- `argocd/applications/dev-application.yaml`
- `argocd/applications/prod-application.yaml`

```yaml
spec:
  source:
    repoURL: https://github.com/<your-username>/<your-repo>.git
```

### Adjust Sync Settings

Disable auto-sync for manual control:

```yaml
syncPolicy:
  automated: null  # Remove this section
  syncOptions:
    - CreateNamespace=true
```

### Test Kustomize Locally

```bash
# Preview dev environment
kubectl kustomize k8s/overlays/dev

# Preview prod environment
kubectl kustomize k8s/overlays/prod

# Apply directly (without ArgoCD)
kubectl apply -k k8s/overlays/dev
```

## 📚 Learn More

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [GitOps Principles](https://opengitops.dev/)

## 🐛 Troubleshooting

### Application stuck in "OutOfSync"

```bash
argocd app sync gitops-demo-app-dev --force
```

### Connection issues to GitHub

Check if ArgoCD can access your repository:

```bash
argocd repo add https://github.com/<your-username>/<your-repo>.git --insecure-skip-server-verification
```

### Check ArgoCD logs

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```
