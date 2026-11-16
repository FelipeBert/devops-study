# Minikube: essential commands

Minikube runs a local Kubernetes cluster for learning and development. Start
Docker or another configured Minikube driver before creating the cluster.

```powershell
# Start a local cluster using the default profile.
minikube start

# Start a named profile when you want more than one local cluster.
minikube start -p study

# Check cluster health and the active profile.
minikube status
minikube profile

# List local Minikube profiles.
minikube profile list

# Point kubectl at a Minikube profile's context.
kubectl config use-context minikube
kubectl config use-context study

# Open the Kubernetes dashboard in a browser.
minikube dashboard

# Open a service exposed through a NodePort or supported service type.
minikube service <service-name>

# Stop the cluster while preserving its data.
minikube stop

# Delete a profile and its cluster data (destructive).
minikube delete -p study
```

The default Minikube profile is named `minikube`. The selected profile/context
determines which local cluster `kubectl` will control.
