# Pods: comandos essenciais

Pods são a menor unidade implantável do Kubernetes. Um Pod pode conter vários
containers que compartilham a rede e os volumes associados.

```powershell
# "pod" também é aceito como forma singular de "pods".
# Listar Pods no namespace atual ou em todos os namespaces.
kubectl get pod
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide

# Consultar um Pod com colunas de nó/IP ou exibir sua definição YAML completa.
kubectl get pod <pod-name> -o wide
kubectl get pod <pod-name> -o yaml

# Inspecionar agendamento, estado, eventos e configuração de um Pod.
kubectl describe pod <pod-name>

# describe apresenta informações de diagnóstico e não aceita "-o yaml".
# Para obter YAML, use "kubectl get pod <pod-name> -o yaml".

# Criar um Pod simples de forma imperativa, para praticar.
kubectl run nginx --image=nginx:stable

# Criar ou atualizar Pods descritos em um manifesto YAML.
kubectl apply -f .\pod1.yaml

# O manifesto de exemplo define metadata.namespace; esse namespace precisa
# existir antes da aplicação (consulte namespace-commands.md).

# Consultar um Pod pelo nome em um namespace específico.
kubectl get pod <pod-name> -n <namespace>

# Ler a saída de um container; use -f para acompanhar novas linhas.
kubectl logs <pod-name>
kubectl logs -f <pod-name>

# Em um Pod com vários containers, indique o container desejado.
kubectl logs <pod-name> -c <container-name>

# Executar um comando dentro do container (exemplo de shell interativo).
kubectl exec -it <pod-name> -- sh

# Excluir um Pod pelo nome ou remover recursos declarados em um manifesto.
kubectl delete pod <pod-name>
kubectl delete -f .\pod1.yaml
```

Pods criados diretamente não são recriados automaticamente quando excluídos.
Para workloads duradouros, use um Deployment. Para acesso pela rede, prefira
um Service em vez de depender do IP do Pod ou apenas de `containerPort`.

`vim`, `clear` e `history` são utilitários do shell, não comandos Kubernetes.
A disponibilidade e a sintaxe dependem do shell e do sistema operacional.
