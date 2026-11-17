# Minikube: comandos essenciais

O Minikube executa um cluster Kubernetes local para estudo e desenvolvimento.
Antes de criar o cluster, inicie o Docker ou outro driver configurado para
o Minikube.

```powershell
# Iniciar um cluster local usando o perfil padrão.
minikube start

# Iniciar um perfil nomeado para manter mais de um cluster local.
minikube start -p study

# Verificar o estado do cluster e o perfil ativo.
minikube status
minikube profile

# Listar os perfis locais do Minikube.
minikube profile list

# Alterar o contexto do kubectl para o perfil do Minikube desejado.
kubectl config use-context minikube
kubectl config use-context study

# Abrir o dashboard do Kubernetes no navegador.
minikube dashboard

# Abrir um Service exposto por NodePort ou outro tipo compatível.
minikube service <service-name>

# Parar o cluster sem apagar seus dados.
minikube stop

# Excluir um perfil e os dados do cluster (operação destrutiva).
minikube delete -p study
```

O nome do perfil padrão do Minikube é `minikube`. O perfil e o contexto
selecionados determinam qual cluster local será controlado pelo `kubectl`.
