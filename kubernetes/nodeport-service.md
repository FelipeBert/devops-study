# NodePort Service

A Kubernetes Service gives a stable way to reach a changing set of Pods. A
`NodePort` Service also exposes that Service on a port of each cluster node.
It is useful for learning and simple access, but production applications
typically use an Ingress or a cloud `LoadBalancer` where appropriate.

## Example manifest

Save this as `service-defs.yml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: NodePort
  ports:
    - targetPort: 80
      port: 80
      nodePort: 30005
      protocol: TCP
  selector:
    app: frontend
```

The Service selector must match labels on the target Pods, for example:

```yaml
metadata:
  labels:
    app: frontend
```

If no Pods have the matching label (or no matching Pods are ready), the
Service has no usable backends. Check the Service's EndpointSlices when
troubleshooting.

## What the port fields mean

| Field | Example | Purpose |
| --- | ---: | --- |
| `targetPort` | `80` | Port on the selected Pod/container that receives traffic. |
| `port` | `80` | Port clients use on the Kubernetes Service's stable ClusterIP. |
| `nodePort` | `30005` | Port opened on each node IP for access from outside the cluster. |
| `protocol` | `TCP` | Transport protocol; TCP is also the default when omitted. |

Traffic to `<node-ip>:30005` is forwarded by the Service to a selected Pod's
port `80`. The Service also gets a ClusterIP, so in-cluster clients can use
`<service-name>:80`. `nodePort` is normally allocated automatically if it is
omitted; when specified, it must be available and within the cluster's
configured NodePort range (commonly `30000-32767`).

## Apply and inspect

`kubectl apply` is the declarative workflow: create the Service if absent or
update it to match the manifest.

```powershell
# Create the Service once from the manifest.
kubectl create -f .\service-defs.yml

# Create or update it declaratively; prefer this for repeatable changes.
kubectl apply -f .\service-defs.yml

# List Services in the current namespace; "svc" is short for "services".
kubectl get svc
kubectl get svc <service-name>

# Inspect the selector, ports, and related events.
kubectl describe svc <service-name>

# Confirm matching Pods and their labels.
kubectl get pods -l app=frontend -o wide

# List Services and legacy Endpoints together; "ep" is short for "endpoints".
kubectl get svc,ep

# EndpointSlices are the modern view of a Service's backend addresses.
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

Unlike `apply`, `create` reports an error if the Service already exists and
does not update it. Choose one of these commands when first creating a Service;
use `apply` when you want to safely reapply changes.

## Reading the sample output

- `TYPE NodePort` confirms the Service is exposed using a node port.
- `CLUSTER-IP 10.110.3.28` is the Service's internal, stable cluster address.
- `EXTERNAL-IP <none>` is expected: a NodePort does not allocate a cloud
  load-balancer IP.
- `PORT(S) 80:30005/TCP` means Service port `80` is mapped to node port `30005`
  using TCP.
- `Selector: app=frontend` identifies the Pod label the Service routes to.
- `TargetPort: 80/TCP` is the destination port on selected Pods.
- `NodePort: 30005/TCP` is the externally reachable port on each node.
- `Endpoints: 172.17.0.4:80` is a backend Pod address and port at the time of
  the command. Pod IPs can change, so clients should use the Service rather
  than depend on this address.

Exact ClusterIP, endpoint IPs, and output formatting vary by cluster and run.
The `kubernetes` Service shown by `kubectl get svc` is the cluster's built-in
API Service, not part of this example.

## Test access

On a network that can reach the nodes, find a node address and request the
NodePort. The node IP must be reachable and any firewall or cloud security
rules must allow the port.

```powershell
# List node addresses; choose an address reachable from your machine.
kubectl get nodes -o wide

# Replace <node-ip> with a reachable node address.
curl.exe http://<node-ip>:30005
```

For Minikube, use its helper to get a URL appropriate to the local driver:

```powershell
minikube service <service-name> --url
```

## Pod IPs and port forwarding

The Service selector determines which Pods receive traffic. List matching
Pods with their IP and node information; this is more reliable than parsing
human-readable `describe` output with shell-specific tools such as `grep`.

```powershell
# Show Pod IPs and nodes for Pods selected by this Service.
kubectl get pods -l app=frontend -o wide

# Inspect one selected Pod and its events.
kubectl describe pod <pod-name>
```

Port forwarding is a separate access method from NodePort. It creates a
temporary connection through the Kubernetes API server from a local port to
the Service port; it does not change the Service type or `nodePort`.

```powershell
# Forward local port 30001 to the Service's port 8090.
kubectl port-forward svc/<service-name> 30001:8090

# Optional: explicitly listen on every local network interface.
kubectl port-forward --address 0.0.0.0 svc/<service-name> 30001:8090
```

The mapping format is `<local-port>:<service-port>`. The history's Service
used port `8090`; the example manifest in this guide uses Service port `80`,
so for that manifest the equivalent command is
`kubectl port-forward svc/<service-name> 30001:80`.

The command stays in the foreground until stopped (Ctrl+C). By default,
port-forward listens only on localhost. `--address 0.0.0.0` listens on all
interfaces and may expose the application to other machines; use it only when
that exposure is intentional and network access is controlled.
