# Service do tipo ClusterIP

Um Service `ClusterIP` fornece um IP virtual e um nome DNS estáveis para
acessar Pods correspondentes de dentro do cluster Kubernetes. É o tipo padrão
de Service e não pode ser acessado diretamente de fora do cluster.

## Exemplos de manifestos

O Service e o Pod podem ser salvos em arquivos separados. Aplique ambos no
mesmo namespace para que o Service possa selecionar o Pod.

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

O seletor do Service `app: backend` corresponde à mesma label no Pod. A label
adicional `project: infinity` pode ajudar a organizar ou selecionar o Pod,
mas não afeta este Service porque não faz parte de seu seletor.

## Como funcionam as portas e o endereço

| Campo | Exemplo | Finalidade |
| --- | ---: | --- |
| `port` | `8080` | Porta usada pelos clientes no Service. |
| `targetPort` | `8080` | Porta de cada Pod selecionado que recebe o tráfego. |
| `containerPort` | `8080` | Documenta a porta em que o container escuta; não expõe o Pod. |
| `protocol` | `TCP` | Protocolo de transporte usado pelo Service. |

Neste exemplo, um cliente dentro do cluster se conecta a
`app-service:8080`. O Kubernetes encaminha a conexão para a porta `8080` de
um dos Pods prontos que correspondem a `app: backend`. O Service recebe um
ClusterIP automaticamente, estável durante sua existência, enquanto os IPs
dos Pods podem mudar.

No mesmo namespace, os clientes podem usar o nome do Service. A partir de
outro namespace, use um nome DNS qualificado, como
`app-service.<namespace>.svc.cluster.local`.

## Aplicar e inspecionar

```powershell
# Criar ou atualizar o Pod e o Service a partir de seus manifestos.
kubectl apply -f .\tom-app.yml
kubectl apply -f .\tom-svc-clusterip.yml

# Consultar o IP e a porta internos do Service.
kubectl get svc <service-name>
kubectl describe svc <service-name>

# Verificar se o seletor encontra Pods e se eles estão prontos.
kubectl get pods -l app=backend --show-labels -o wide

# Consultar os endereços dos backends do Service.
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

Se o Service não tiver endpoints prontos, verifique se o Pod possui a label
esperada, está no mesmo namespace e está pronto. `Endpoints` ou
`EndpointSlices` exibem os endereços dos Pods selecionados pelo Service.

## Testar o acesso

De outro Pod no cluster que tenha um cliente de rede adequado, acesse o
Service pelo nome DNS:

```text
http://<service-name>:8080
```

Para desenvolvimento local, `kubectl port-forward` pode criar um túnel
temporário de uma porta local para o Service:

```powershell
kubectl port-forward svc/<service-name> 8080:8080
```

Depois, acesse `http://127.0.0.1:8080` na máquina que executa `kubectl`. Isso
não altera o tipo do Service nem torna seu ClusterIP acessível externamente;
o processo de encaminhamento precisa continuar em execução.
