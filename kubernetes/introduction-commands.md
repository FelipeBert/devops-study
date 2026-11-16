# Kubernetes introduction: essential commands

`kubectl` is the command-line client for the Kubernetes API. These commands
inspect a cluster and apply declarative manifests.

```powershell
# Confirm the kubectl client is installed.
kubectl version --client

# Check which cluster and API endpoint the current context points to.
kubectl cluster-info

# List cluster nodes and their readiness.
kubectl get nodes

# List common resources across all namespaces.
kubectl get all --all-namespaces

# List available API resource kinds and their short names.
kubectl api-resources

# Explain a resource's schema and supported fields.
kubectl explain pod
kubectl explain pod.spec.containers

# Create or update resources described by a manifest (declarative workflow).
kubectl apply -f .\pod1.yaml

# Inspect what changed in a manifest before applying it.
kubectl diff -f .\pod1.yaml

# Display the current client and server versions.
kubectl version
```

`kubectl get` is a quick overview; use `kubectl describe` for events and
diagnostic details about a specific resource.
