# Pods: essential commands

Pods are the smallest deployable Kubernetes unit. A Pod can contain multiple
containers that share networking and attached volumes.

```powershell
# List Pods in the current namespace, or in every namespace.
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide

# Inspect a Pod's scheduling, status, events, and configuration.
kubectl describe pod <pod-name>

# Create a simple Pod imperatively for practice.
kubectl run nginx --image=nginx:stable

# Create or update Pods described in a YAML manifest.
kubectl apply -f .\pod1.yaml

# Read container output; add -f to follow new log lines.
kubectl logs <pod-name>
kubectl logs -f <pod-name>

# For a multi-container Pod, select the container explicitly.
kubectl logs <pod-name> -c <container-name>

# Run a command inside a container (interactive shell example).
kubectl exec -it <pod-name> -- sh

# Delete a Pod by name or remove resources declared in a manifest.
kubectl delete pod <pod-name>
kubectl delete -f .\pod1.yaml
```

Pods created directly are not automatically recreated if deleted. For
long-lived workloads, use a Deployment; expose network access through a
Service rather than relying on a Pod IP or `containerPort` alone.
