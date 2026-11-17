# Deployments

Um `Deployment` declara e mantém o estado desejado de uma aplicação, como a
imagem dos containers e a quantidade de réplicas. É a forma recomendada de
gerenciar workloads stateless: ele coordena atualizações e reversões sem
precisar administrar ReplicaSets diretamente.

## Exemplo de manifesto

Salve como `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  # Quantidade de Pods que o Deployment deve manter.
  replicas: 3
  selector:
    # O seletor deve corresponder às labels do template de Pod.
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          # Em produção, use uma versão suportada e aprovada pela sua equipe.
          image: nginx:1.14.2
          ports:
            - containerPort: 80
```

O seletor em `spec.selector.matchLabels` precisa corresponder às labels em
`spec.template.metadata.labels`. O Deployment usa esse seletor para gerenciar
seus Pods; seletores não podem ser alterados depois da criação do recurso.
O manifesto usa uma imagem antiga apenas para acompanhar o exemplo de estudo:
não a adote em produção.

## Relação entre Deployment, ReplicaSet e Pods

O Deployment não cria e gerencia os Pods diretamente. Ele cria um ReplicaSet,
que por sua vez cria e mantém os Pods:

```text
Deployment
└── ReplicaSet
    ├── Pod
    ├── Pod
    └── Pod
```

O ReplicaSet garante o número de Pods desejado. Quando o template do Pod muda
(por exemplo, uma nova imagem), o Deployment cria um novo ReplicaSet e coordena
o rollout. Com a estratégia padrão `RollingUpdate`, as réplicas migram
gradualmente para a nova versão, conforme os limites de atualização definidos.
ReplicaSets antigos podem ser mantidos para permitir rollback.

## Aplicar e acompanhar

```powershell
# Conferir as mudanças propostas pelo manifesto.
kubectl diff -f .\deployment.yaml

# Criar o Deployment ou atualizar o cluster para corresponder ao arquivo.
kubectl apply -f .\deployment.yaml

# Listar Deployments, ReplicaSets e Pods.
kubectl get deployments
kubectl get rs
kubectl get pods

# Inspecionar o Deployment e acompanhar o resultado do rollout.
kubectl describe deployment <deployment-name>
kubectl rollout status deployment/<deployment-name>

# Inspecionar um Pod criado pelo Deployment.
kubectl describe pod <pod-name>
```

Os nomes dos Pods incluem sufixos gerados e mudam durante rollouts ou
recriações. Para encontrá-los, use `kubectl get pods` ou filtre pelas labels
do manifesto, por exemplo `kubectl get pods -l app=nginx`.

## Atualizar a imagem e reverter

Alterar a imagem no manifesto e aplicar o arquivo é o fluxo recomendado.
`kubectl set image` também atualiza a imagem no recurso ativo, o que é útil
para uma alteração rápida, mas não atualiza o YAML local.

```powershell
# Atualizar a imagem diretamente no Deployment ativo.
kubectl set image deployment/<deployment-name> <container-name>=<imagem>:<tag>

# Conferir o progresso e os ReplicaSets criados pelo rollout.
kubectl rollout status deployment/<deployment-name>
kubectl get rs
kubectl get pods

# Consultar o histórico de rollouts.
kubectl rollout history deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name> --revision=2

# Reverter para a revisão anterior.
kubectl rollout undo deployment/<deployment-name>

# Ou reverter para uma revisão específica.
kubectl rollout undo deployment/<deployment-name> --to-revision=2
```

O comando do histórico `kubectl set image deployment.v1.apps/...` é uma forma
válida de identificar o recurso por API group e versão. A forma mais curta
`deployment/<deployment-name>` costuma ser suficiente.

Uma nova revisão é criada quando muda o template dos Pods, como ao alterar a
imagem. Uma simples mudança no número de réplicas não cria uma revisão de
rollout. O histórico disponível depende de quantas revisões antigas o
Deployment mantém (`revisionHistoryLimit`).

## Escalar

Para mudar a quantidade de réplicas de forma durável, atualize `spec.replicas`
no arquivo versionado e aplique-o. O comando `scale` altera somente o estado
ativo do cluster:

```powershell
kubectl scale deployment/<deployment-name> --replicas=1
kubectl get deployment <deployment-name>
kubectl get pods
```

Se o YAML ainda declarar três réplicas, uma aplicação posterior do manifesto
pode restaurar essa quantidade. Para uma mudança permanente, atualize o YAML,
revise a alteração e aplique-o.

## Por que preferir o arquivo YAML a alterações diretas pela CLI?

Comandos como `kubectl set image`, `kubectl scale` e `kubectl edit` modificam o
objeto ativo no cluster, mas não alteram automaticamente o arquivo no
repositório. Isso pode criar *configuration drift*: o estado em execução fica
diferente da configuração versionada.

Manter o YAML como fonte de verdade e aplicar com `kubectl apply -f` ajuda a:

- **Reproduzir** a configuração em outros clusters e ambientes.
- **Revisar** mudanças antes de aplicá-las.
- **Rastrear** alterações no Git e saber quem as introduziu.
- **Evitar drift** entre o cluster e a configuração declarada.

Alterações imperativas podem ser úteis para aprendizado ou resposta pontual a
um incidente. Se forem usadas para uma mudança permanente, atualize o arquivo
de definição para que ele continue refletindo o estado desejado. Em ambientes
gerenciados por GitOps, alterações feitas diretamente no cluster podem ser
sobrescritas pelo reconciliador.

## Excluir um Deployment

```powershell
# Excluir os recursos gerenciados por este Deployment.
kubectl delete deployment <deployment-name>

# Conferir Deployments, ReplicaSets e Pods restantes.
kubectl get deployments
kubectl get rs
kubectl get pods
```

Ao excluir o Deployment, o Kubernetes normalmente também remove os ReplicaSets
e Pods que ele gerencia. Não use esse comando apenas para substituir Pods: o
Deployment já cuida da recuperação e atualização deles.

## Comandos do histórico que não são do Kubernetes

`vim`, `clear` e `history` são utilitários do shell. `top` também é um utilitário
do sistema operacional; para consultar métricas dos Pods no Kubernetes, use
`kubectl top pods`, desde que o cluster tenha a Metrics API, normalmente
fornecida pelo Metrics Server. `kubetl` no histórico é um erro de digitação;
o comando correto é `kubectl`.
