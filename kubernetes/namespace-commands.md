# Namespaces: comandos essenciais

Namespaces oferecem separação lógica para recursos namespaced de um cluster.
Eles não substituem controles de acesso nem isolam recursos com escopo de
cluster.

```powershell
# Listar namespaces e inspecionar um deles.
kubectl get namespaces
kubectl describe namespace <namespace>

# Criar um namespace de forma imperativa.
kubectl create namespace <namespace>
# "ns" é o nome abreviado de "namespace".
kubectl create ns <namespace>

# Listar recursos em um namespace ou Pods em todos os namespaces.
kubectl get all -n <namespace>
kubectl get pods --all-namespaces

# Direcionar um único comando para um namespace.
kubectl get pods -n <namespace>
kubectl apply -n <namespace> -f .\pod1.yaml
kubectl get pod <pod-name> -n <namespace>

# Definir um namespace padrão para o contexto atual.
kubectl config set-context --current --namespace=<namespace>

# Restaurar "default" como namespace padrão do contexto atual.
kubectl config set-context --current --namespace=default

# Excluir um namespace e seus recursos namespaced (operação destrutiva).
kubectl delete namespace <namespace>
```

`metadata.namespace` no manifesto define onde o recurso será criado. Se esse
campo for omitido, o Kubernetes usa a opção `-n` ou o namespace padrão do
contexto. A opção `-n` não substitui um namespace definido explicitamente no
manifesto. Excluir um namespace também exclui seus recursos namespaced.
