# GitOps Demo App

A simple Node.js application for learning GitOps with ArgoCD.

## Features

- Simple Express.js REST API
- Health check endpoint
- Dockerized application
- Ready for GitOps deployment

## Endpoints

- `GET /` - Returns a welcome message with app info
- `GET /health` - Health check endpoint

## Local Development

### Prerequisites

- Node.js 18+ 
- npm

### Running Locally

```bash
# Install dependencies
npm install

# Start the server
npm start
```

The application will be available at `http://localhost:3000`

## Docker

### Build the Docker image

```bash
docker build -t gitops-demo-app:latest .
```

### Run the Docker container

```bash
docker run -p 3000:3000 gitops-demo-app:latest
```

## GitOps Deployment

This application is designed to be deployed using ArgoCD. When changes are merged to the main branch, ArgoCD will automatically sync and deploy the new version.

### Testing the deployment

```bash
# Test the main endpoint
curl http://localhost:3000/

# Test the health endpoint
curl http://localhost:3000/health
```

## Version History

- v1.0.0 - Initial release
