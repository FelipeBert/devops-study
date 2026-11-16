# kubeconfig: contexts and credentials

A kubeconfig file stores cluster endpoints, user credentials, and contexts.
A context combines a cluster, a user, and optionally a default namespace.

```powershell
# Show the current context and the contexts available to kubectl.
kubectl config current-context
kubectl config get-contexts

# Show the active context's configuration (sensitive values may be present).
kubectl config view --minify

# Switch the active context to another configured cluster.
kubectl config use-context <context-name>

# Set the default namespace for the current context.
kubectl config set-context --current --namespace=<namespace>

# Create a named context from an existing cluster and user.
kubectl config set-context <context-name> `
  --cluster=<cluster-name> `
  --user=<user-name> `
  --namespace=<namespace>

# Run one command with a specific kubeconfig file.
kubectl --kubeconfig .\config get nodes

# On PowerShell, select a kubeconfig file for subsequent kubectl commands.
$env:KUBECONFIG = 'C:\path\to\config'
```

Treat kubeconfig files like credentials: do not commit them or paste their
contents into logs or chat. `--context` and `--namespace` flags can override
the current defaults for a single command.
