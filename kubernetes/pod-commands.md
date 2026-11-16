# Pods: essential commands

Pods are the smallest deployable Kubernetes unit. A Pod can contain multiple
containers that share networking and attached volumes.

```powershell
# "pod" is accepted as a singular alias for "pods".
# List Pods in the current namespace, or in every namespace.
kubectl get pod
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide

# Inspect one Pod with its node/IP columns or its full YAML definition.
kubectl get pod <pod-name> -o wide
kubectl get pod <pod-name> -o yaml

# Inspect a Pod's scheduling, status, events, and configuration.
kubectl describe pod <pod-name>

# describe is a human-readable diagnostic view and does not support "-o yaml".
# Use "kubectl get pod <pod-name> -o yaml" when you need the YAML representation.

# Create a simple Pod imperatively for practice.
kubectl run nginx --image=nginx:stable

# Create or update Pods described in a YAML manifest.
kubectl apply -f .\pod1.yaml

# The sample manifest sets metadata.namespace, so that namespace must exist
# before applying it (see namespace-commands.md).

# Target a Pod by name within a specific namespace.
kubectl get pod <pod-name> -n <namespace>

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

`vim`, `clear`, and `history` in a terminal session are shell utilities, not
Kubernetes commands. Their availability and syntax depend on the shell/OS.
