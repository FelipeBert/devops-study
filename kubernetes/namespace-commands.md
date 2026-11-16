# Namespaces: essential commands

Namespaces provide logical separation for namespaced resources in a cluster.
They do not replace access controls or isolate cluster-scoped resources.

```powershell
# List namespaces and inspect one namespace.
kubectl get namespaces
kubectl describe namespace <namespace>

# Create a namespace imperatively.
kubectl create namespace <namespace>

# List resources in a namespace, or Pods across all namespaces.
kubectl get all -n <namespace>
kubectl get pods --all-namespaces

# Target a namespace for one command.
kubectl get pods -n <namespace>
kubectl apply -n <namespace> -f .\pod1.yaml

# Set a default namespace on the current context.
kubectl config set-context --current --namespace=<namespace>

# Return the current context's default namespace to "default".
kubectl config set-context --current --namespace=default

# Delete a namespace and its namespaced resources (destructive).
kubectl delete namespace <namespace>
```

A manifest's `metadata.namespace` selects where that resource is created. If
it is omitted, Kubernetes uses the `-n` option or the context default. The
`-n` option does not override a namespace explicitly set in the manifest.
Deleting a namespace also deletes its namespaced resources.
