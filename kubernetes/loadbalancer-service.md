# Service do tipo LoadBalancer

Um Service `LoadBalancer` solicita à integração de infraestrutura do cluster
(geralmente um provedor de nuvem) a criação de um balanceador externo e o
encaminhamento do tráfego para os Pods correspondentes. Ele fornece um
endereço externo estável sem exigir que os clientes acessem diretamente um IP
de nó.

## Exemplo de manifesto

Salve como `loadbalancer-service.yaml`:

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

O seletor precisa corresponder às labels dos Pods da aplicação, como
`app: frontend`. `port` é a porta do Service usada pelos clientes;
`targetPort` é a porta dos Pods selecionados.

## Criar e inspecionar o Service

```powershell
# Criar ou atualizar o Service a partir do manifesto.
kubectl apply -f .\loadbalancer-service.yaml

# Acompanhar o Service enquanto a infraestrutura provisiona o endereço externo.
kubectl get svc <service-name> --watch

# Listar Services ou inspecionar o seletor, as portas e os eventos deste Service.
kubectl get svc
kubectl describe svc <service-name>

# Verificar se o seletor encontra Pods da aplicação prontos.
kubectl get pods -l app=frontend -o wide
kubectl get endpointslice -l kubernetes.io/service-name=<service-name>
```

Quando o provisionamento terminar, `kubectl get svc` normalmente mostrará
`TYPE LoadBalancer` e um endereço ou hostname em `EXTERNAL-IP`. O valor pode
continuar como `<pending>` se o cluster não tiver integração com balanceador
ou se o provisionamento ainda estiver em andamento. Um Service
`LoadBalancer` também possui um ClusterIP para tráfego interno; algumas
implementações alocam ainda um NodePort.

Para testar um endereço acessível a partir da sua máquina:

```powershell
curl.exe http://<external-ip-or-hostname>:80
```

Substitua o placeholder pelo endereço exibido por `kubectl get svc`. As regras
de firewall e de segurança do provedor precisam permitir o tráfego. Em um
cluster Minikube local, pode ser necessário executar `minikube tunnel` para
disponibilizar os endereços LoadBalancer; mantenha o comando em outro
terminal.

## LoadBalancer versus port-forward

O histórico inclui comandos como:

```powershell
kubectl port-forward svc/<service-name> 80:80
kubectl --kubeconfig <path-to-kubeconfig> port-forward svc/<service-name> 80:80
```

`port-forward` cria uma conexão temporária da porta local `80` para a porta
`80` do Service, tunelada pela API Kubernetes. Ele **não** cria um
balanceador de carga na nuvem, não altera o tipo do Service e não fornece um
endereço externo permanente. O comando fica em primeiro plano até ser
interrompido.

Por padrão, port-forward escuta apenas em localhost. Adicionar
`--address 0.0.0.0` faz com que escute em todas as interfaces de rede locais,
o que pode expor a aplicação a outras máquinas. Use essa opção somente se a
exposição for intencional e o acesso à rede estiver controlado. Para testes
locais, uma porta local alta (por exemplo, `8080:80`) normalmente evita a
necessidade de privilégios elevados:

```powershell
kubectl port-forward svc/<service-name> 8080:80
```

A opção `--kubeconfig` seleciona um arquivo específico de
configuração/credenciais quando o contexto padrão não for o desejado:

```powershell
kubectl --kubeconfig <path-to-kubeconfig> get svc
kubectl --kubeconfig <path-to-kubeconfig> port-forward svc/<service-name> 8080:80
```

Normalmente, `kubectl` não precisa de `sudo`. Executá-lo como root pode usar o
kubeconfig e as credenciais padrão de outro usuário; especifique o
`--kubeconfig` desejado ou configure o acesso do usuário atual. Em alguns
sistemas operacionais, vincular uma porta local abaixo de 1024, como `80`,
também pode exigir privilégios elevados.
