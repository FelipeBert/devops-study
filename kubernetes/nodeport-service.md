# Service do tipo NodePort

Um Service do Kubernetes oferece um endereço estável para acessar Pods que
podem mudar. Um Service `NodePort` também expõe esse Service em uma porta de
cada nó do cluster. É útil para estudo e acesso simples; em produção,
normalmente se usa um Ingress ou um `LoadBalancer` de nuvem, conforme o caso.

## Exemplo de manifesto

Salve como `service-defs.yml`:

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

O seletor do Service precisa corresponder às labels dos Pods de destino, por
exemplo:

```yaml
metadata:
  labels:
    app: frontend
```

Se nenhum Pod tiver a label correspondente (ou se nenhum Pod correspondente
estiver pronto), o Service não terá backends utilizáveis. Ao investigar o
problema, consulte os EndpointSlices do Service.

## Significado dos campos de porta

| Campo | Exemplo | Finalidade |
| --- | ---: | --- |
| `targetPort` | `80` | Porta do Pod/container selecionado que recebe o tráfego. |
| `port` | `80` | Porta usada pelos clientes no ClusterIP estável do Service. |
| `nodePort` | `30005` | Porta aberta no IP de cada nó para acesso externo ao cluster. |
| `protocol` | `TCP` | Protocolo de transporte; TCP também é o padrão quando omitido. |

O Service encaminha o tráfego de `<node-ip>:30005` para a porta `80` de um Pod
selecionado. O Service também recebe um ClusterIP, então clientes dentro do
cluster podem usar `<service-name>:80`. Se `nodePort` for omitido, ele
normalmente será alocado automaticamente. Quando especificado, precisa estar
disponível e dentro do intervalo configurado para NodePort (comumente
`30000-32767`).

## Aplicar e inspecionar

`kubectl apply` segue o fluxo declarativo: cria o Service se ele não existir
ou o atualiza para corresponder ao manifesto.

```powershell
# Criar o Service uma vez a partir do manifesto.
kubectl create -f .\service-defs.yml

# Criar ou atualizar declarativamente; prefira para mudanças repetíveis.
kubectl apply -f .\service-defs.yml

# Listar Services no namespace atual; "svc" abrevia "services".
kubectl get svc
kubectl get svc <service-name>

# Inspecionar o seletor, as portas e os eventos relacionados.
kubectl describe svc <service-name>

# Confirmar quais Pods correspondem ao seletor e quais labels possuem.
kubectl get pods -l app=frontend -o wide

# Listar Services e Endpoints legados juntos; "ep" abrevia "endpoints".
kubectl get svc,ep

# EndpointSlices são a forma atual de consultar os endereços dos backends.
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

Ao contrário de `apply`, `create` retorna erro se o Service já existir e não
o atualiza. Escolha um dos comandos para a criação inicial; use `apply` para
reaplicar mudanças com segurança.

## Como interpretar a saída de exemplo

- `TYPE NodePort` confirma que o Service é exposto por uma porta dos nós.
- `CLUSTER-IP 10.110.3.28` é o endereço interno e estável do Service no cluster.
- `EXTERNAL-IP <none>` é esperado: um NodePort não cria um IP de
  balanceador de carga na nuvem.
- `PORT(S) 80:30005/TCP` indica que a porta `80` do Service está associada à
  porta NodePort `30005`, usando TCP.
- `Selector: app=frontend` identifica a label dos Pods para os quais o Service
  encaminha o tráfego.
- `TargetPort: 80/TCP` é a porta de destino nos Pods selecionados.
- `NodePort: 30005/TCP` é a porta acessível em cada nó.
- `Endpoints: 172.17.0.4:80` é o endereço e a porta de um Pod backend naquele
  momento. IPs de Pods podem mudar; clientes devem usar o Service, não esse
  endereço diretamente.

O ClusterIP, os IPs dos endpoints e a formatação da saída variam entre
clusters e execuções. O Service `kubernetes` exibido por `kubectl get svc` é
o Service de API integrado ao cluster, não faz parte deste exemplo.

## Testar o acesso

Em uma rede que alcance os nós, encontre o endereço de um deles e acesse a
NodePort. O IP do nó precisa estar acessível, e as regras de firewall ou de
segurança na nuvem devem permitir essa porta.

```powershell
# Listar os endereços dos nós; escolha um acessível a partir da sua máquina.
kubectl get nodes -o wide

# Substituir <node-ip> por um endereço de nó acessível.
curl.exe http://<node-ip>:30005
```

No Minikube, use este comando para obter uma URL adequada ao driver local:

```powershell
minikube service <service-name> --url
```

## IPs dos Pods e encaminhamento de portas

O seletor do Service determina quais Pods recebem tráfego. Liste os Pods
correspondentes com seus IPs e nós; isso é mais confiável do que analisar a
saída legível de `describe` com ferramentas de shell como `grep`.

```powershell
# Exibir os IPs e os nós dos Pods selecionados por este Service.
kubectl get pods -l app=frontend -o wide

# Inspecionar um Pod selecionado e seus eventos.
kubectl describe pod <pod-name>
```

O encaminhamento de portas é diferente do NodePort. Ele cria uma conexão
temporária, via servidor da API Kubernetes, de uma porta local para a porta do
Service; não altera o tipo do Service nem o `nodePort`.

```powershell
# Encaminhar a porta local 30001 para a porta 8090 do Service.
kubectl port-forward svc/<service-name> 30001:8090

# Opcional: escutar explicitamente em todas as interfaces de rede locais.
kubectl port-forward --address 0.0.0.0 svc/<service-name> 30001:8090
```

O formato do mapeamento é `<porta-local>:<porta-do-service>`. O Service do
histórico usava a porta `8090`; o manifesto de exemplo deste guia usa a porta
`80`. Portanto, para esse manifesto, o comando equivalente é
`kubectl port-forward svc/<service-name> 30001:80`.

O comando permanece em primeiro plano até ser interrompido (Ctrl+C). Por
padrão, `port-forward` escuta apenas em localhost. `--address 0.0.0.0` escuta
em todas as interfaces e pode expor a aplicação a outras máquinas; use essa
opção somente quando a exposição for intencional e o acesso à rede estiver
controlado.
