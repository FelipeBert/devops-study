# ClusterIP Service

A `ClusterIP` Service provides a stable virtual IP and DNS name for reaching
matching Pods from inside the Kubernetes cluster. It is the default Service
type and is not directly reachable from outside the cluster.

## Example manifests

The Service and Pod can be saved as separate files. Apply both in the same
namespace so the Service can select the Pod.

### `tom-svc-clusterip.yml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: ClusterIP
  ports:
    - targetPort: 8080
      port: 8080
      protocol: TCP
  selector:
    app: backend
```

### `tom-app.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: backend
    project: infinity
spec:
  containers:
    - name: tomcat-container
      image: tomcat
      ports:
        - name: app-port
          containerPort: 8080
```

The Service selector `app: backend` matches the same label on the Pod. The
additional `project: infinity` label is useful for organizing or selecting the
Pod, but it does not affect this Service because that label is not in the
Service selector.

## How the ports and address work

| Field | Example | Purpose |
| --- | ---: | --- |
| `port` | `8080` | Port clients use on the Service. |
| `targetPort` | `8080` | Port on each selected Pod that receives traffic. |
| `containerPort` | `8080` | Documents the port the container listens on; it does not expose the Pod. |
| `protocol` | `TCP` | Transport protocol used by the Service. |

In this example, a client inside the cluster connects to
`app-service:8080`. Kubernetes routes the connection to port `8080` on one of
the ready Pods matching `app: backend`. The Service receives a ClusterIP
automatically; it is stable for the lifetime of the Service, while Pod IPs
can change.

Within the same namespace, clients can use the Service name. From another
namespace, use a qualified DNS name such as
`app-service.<namespace>.svc.cluster.local`.

## Apply and inspect

```powershell
# Create or update the Pod and Service from their manifests.
kubectl apply -f .\tom-app.yml
kubectl apply -f .\tom-svc-clusterip.yml

# Find the Service's internal IP and port.
kubectl get svc <service-name>
kubectl describe svc <service-name>

# Check whether the selector matches Pods and whether they are ready.
kubectl get pods -l app=backend --show-labels -o wide

# Inspect the Service's backend addresses.
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

If the Service has no ready endpoints, check that the Pod has the expected
label, is in the same namespace, and is ready. `Endpoints` or `EndpointSlices`
show the backend Pod addresses selected by the Service.

## Test access

From another Pod in the cluster that has a suitable network client, request
the Service by DNS name:

```text
http://<service-name>:8080
```

For local development, `kubectl port-forward` can temporarily tunnel a local
port to the Service:

```powershell
kubectl port-forward svc/<service-name> 8080:8080
```

Then access `http://127.0.0.1:8080` on the machine running `kubectl`. This
does not change the Service type or make its ClusterIP externally reachable;
the forwarding process must stay running.
