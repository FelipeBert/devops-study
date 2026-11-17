# ReplicaSets

Um `ReplicaSet` mantém em execução o número desejado de Pods que correspondem
a um seletor de labels. Se um Pod gerenciado for apagado ou ficar abaixo da
quantidade desejada, o controller cria outro para reconciliar o estado atual
com o estado declarado.

## Exemplo de manifesto

Salve como `replicaset.yaml`:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # Número de Pods que o ReplicaSet deve manter.
  replicas: 3
  selector:
    # O seletor precisa corresponder às labels do template abaixo.
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        # Esta label permite ao ReplicaSet encontrar e gerenciar os Pods.
        tier: frontend
    spec:
      containers:
        - name: php-redis
          image: us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5
```

O seletor `tier: frontend` deve coincidir com as labels em
`spec.template.metadata.labels`. Se ele não corresponder, o ReplicaSet não
consegue gerenciar os Pods esperados. As labels em `metadata.labels` do próprio
ReplicaSet servem para identificar o recurso; elas não substituem as labels do
template.

## Criar e inspecionar

```powershell
# Criar o ReplicaSet uma vez a partir do manifesto.
kubectl create -f .\replicaset.yaml

# Aplicar declarativamente: cria o recurso ou atualiza para refletir o arquivo.
kubectl apply -f .\replicaset.yaml

# Comparar o manifesto local com o estado atual antes de aplicar.
kubectl diff -f .\replicaset.yaml

# Listar ReplicaSets ("rs" é o nome abreviado) e seus Pods disponíveis/desejados.
kubectl get rs

# Inspecionar detalhes, selector, eventos e estado do ReplicaSet.
kubectl describe rs <replicaset-name>

# Listar os Pods correspondentes ao selector do exemplo.
kubectl get pods -l tier=frontend -o wide

# Acompanhar os Pods enquanto o controller reconcilia a quantidade desejada.
kubectl get pods --watch
```

`kubectl create -f` é útil para criar um recurso que ainda não existe, mas
retorna erro se ele já existir. `kubectl apply -f` pode ser repetido e é mais
adequado para manter o cluster alinhado com um manifesto versionado.

## Reconciliação e escalabilidade

Apagar um Pod gerenciado não reduz a quantidade desejada: o ReplicaSet percebe
a diferença e cria outro Pod. Isso é útil para entender a reconciliação, mas
não é uma forma de escalar o workload.

```powershell
# Excluir Pods específicos é apenas um teste: o ReplicaSet tenta substituí-los.
kubectl delete pod <pod-name>

# Escalar para uma réplica diretamente no recurso ativo.
kubectl scale --replicas=1 rs/<replicaset-name>

# Verificar a quantidade atual de Pods.
kubectl get rs
kubectl get pods -l tier=frontend
```

O comando `scale` altera o estado ativo do cluster, mas não atualiza o arquivo
YAML. Se o manifesto versionado ainda declarar `replicas: 3`, uma aplicação
posterior dele poderá voltar a quantidade para três. Para uma mudança durável,
atualize `spec.replicas` no manifesto, revise a alteração e aplique o arquivo.

## Por que preferir YAML declarativo a alterações pela CLI?

Comandos como `kubectl scale` e `kubectl edit` alteram diretamente o objeto
ativo no cluster. São práticos para experimentos e situações pontuais, mas
podem deixar o cluster diferente dos arquivos do repositório. Essa divergência
é chamada de *configuration drift*.

Manter o YAML como fonte de verdade e aplicar com `kubectl apply -f` oferece:

- **Reprodutibilidade:** o mesmo manifesto pode ser aplicado em outro ambiente.
- **Histórico e revisão:** Git registra o que mudou, quando e por quem.
- **Colaboração:** mudanças podem ser revisadas antes de chegar ao cluster.
- **Menos drift:** o estado desejado fica explícito em vez de existir apenas
  como uma edição manual no cluster.

`kubectl edit rs/<nome>` é útil para diagnóstico ou aprendizado, mas não altera
o arquivo local. Se usado para uma mudança permanente, copie a alteração de
volta para o manifesto e aplique-o. Em produção, prefira mudanças revisadas e
versionadas; use alterações imperativas apenas quando forem intencionais e
depois reconcilie o arquivo com o estado desejado.

## ReplicaSet ou Deployment?

Normalmente, crie um `Deployment` em vez de gerenciar um `ReplicaSet`
diretamente. O Deployment cria e gerencia ReplicaSets e acrescenta atualizações
progressivas e suporte a rollback. A criação direta de ReplicaSets é útil para
estudo ou casos específicos em que esse controle adicional não é necessário.

O comando `top` visto no histórico é uma ferramenta do sistema operacional,
não um comando do Kubernetes. Para métricas de recursos dos Pods, use
`kubectl top pods`; o cluster precisa ter a Metrics API, normalmente fornecida
pelo Metrics Server.
