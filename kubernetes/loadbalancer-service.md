# LoadBalancer Service

A Kubernetes `LoadBalancer` Service asks the cluster's infrastructure
integration (commonly a cloud provider) to provision an external load balancer
and route traffic to matching Pods. It provides a stable external address
without requiring clients to connect directly to a node IP.

## Example manifest

Save this as `loadbalancer-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

The selector must match labels on the application Pods, such as
`app: frontend`. `port` is the Service port clients use; `targetPort` is the
port on selected Pods.

## Create and inspect the Service

```powershell
# Create or update the Service from its manifest.
kubectl apply -f .\loadbalancer-service.yaml

# Watch the Service while the infrastructure provisions its external address.
kubectl get svc <service-name> --watch

# List Services or inspect this Service's selector, ports, and events.
kubectl get svc
kubectl describe svc <service-name>

# Check whether the selector finds ready application Pods.
kubectl get pods -l app=frontend -o wide
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

When provisioning completes, `kubectl get svc` typically shows
`TYPE LoadBalancer` and an `EXTERNAL-IP` address or hostname. It can remain
`<pending>` if the cluster has no load-balancer integration, or provisioning
is still in progress. A `LoadBalancer` Service also has a ClusterIP for
in-cluster traffic; some implementations additionally allocate a NodePort.

To test an address that is reachable from your machine:

```powershell
curl.exe http://<external-ip-or-hostname>:80
```

Replace the placeholder with the address shown by `kubectl get svc`. Network
firewall rules and the provider's security configuration must allow the
traffic. On a local Minikube cluster, `minikube tunnel` may be needed to make
LoadBalancer addresses available; keep it running in a separate terminal.

## LoadBalancer versus port-forward

The history includes commands like:

```powershell
kubectl port-forward svc/<service-name> 80:80
kubectl --kubeconfig <path-to-kubeconfig> port-forward svc/<service-name> 80:80
```

`port-forward` is a temporary connection from local port `80` to Service port
`80`, tunneled through the Kubernetes API. It does **not** create a cloud load
balancer, change the Service type, or provide a durable external address. It
stays in the foreground until stopped.

By default, port-forward listens only on localhost. Adding
`--address 0.0.0.0` listens on every local network interface, which can expose
the application to other machines. Use that option only when exposure is
intentional and network access is controlled. For local testing, a high local
port (for example `8080:80`) usually avoids needing elevated privileges:

```powershell
kubectl port-forward svc/<service-name> 8080:80
```

The `--kubeconfig` option selects a specific credentials/configuration file
when the default context is not appropriate:

```powershell
kubectl --kubeconfig <path-to-kubeconfig> get svc
kubectl --kubeconfig <path-to-kubeconfig> port-forward svc/<service-name> 8080:80
```

`sudo` is usually unnecessary for `kubectl`. Running it as root can select a
different user's default kubeconfig and credentials; specify the intended
`--kubeconfig` or configure the current user's access instead. Binding a local
port below 1024, such as `80`, may also require elevated privileges on some
operating systems.
