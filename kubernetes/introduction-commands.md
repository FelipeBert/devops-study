# Kubernetes: comandos essenciais para começar

`kubectl` é o cliente de linha de comando da API do Kubernetes. Os comandos
abaixo permitem inspecionar um cluster e aplicar manifestos declarativos.

```powershell
# Confirmar que o cliente kubectl está instalado.
kubectl version --client

# Verificar para qual cluster e endpoint da API o contexto atual aponta.
kubectl cluster-info

# Listar os nós do cluster e verificar se estão prontos.
kubectl get nodes

# Listar recursos comuns em todos os namespaces.
kubectl get all --all-namespaces

# Listar os tipos de recursos da API disponíveis e seus nomes abreviados.
kubectl api-resources

# Consultar o esquema de um recurso e os campos disponíveis.
kubectl explain pod
kubectl explain pod.spec.containers

# Criar ou atualizar recursos descritos em um manifesto (fluxo declarativo).
kubectl apply -f .\pod1.yaml

# Conferir as diferenças antes de aplicar o manifesto.
kubectl diff -f .\pod1.yaml

# Exibir as versões atuais do cliente e do servidor.
kubectl version
```

`kubectl get` oferece uma visão rápida dos recursos. Use `kubectl describe`
para consultar eventos e detalhes de diagnóstico de um recurso específico.
