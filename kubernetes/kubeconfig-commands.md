# kubeconfig: contextos e credenciais

Um arquivo kubeconfig armazena endpoints de clusters, credenciais de usuários
e contextos. Um contexto combina um cluster, um usuário e, opcionalmente,
um namespace padrão.

```powershell
# Exibir o contexto atual e os contextos disponíveis para o kubectl.
kubectl config current-context
kubectl config get-contexts

# Exibir a configuração do contexto ativo (pode conter dados sensíveis).
kubectl config view --minify

# Trocar o contexto ativo para outro cluster configurado.
kubectl config use-context <context-name>

# Definir o namespace padrão do contexto atual.
kubectl config set-context --current --namespace=<namespace>

# Criar um contexto nomeado usando um cluster e um usuário já configurados.
kubectl config set-context <context-name> `
  --cluster=<cluster-name> `
  --user=<user-name> `
  --namespace=<namespace>

# Executar um comando usando um arquivo kubeconfig específico.
kubectl --kubeconfig .\config get nodes

# No PowerShell, selecionar o kubeconfig para os próximos comandos kubectl.
$env:KUBECONFIG = 'C:\path\to\config'
```

Trate arquivos kubeconfig como credenciais: não os envie ao Git nem cole seu
conteúdo em logs ou conversas. As opções `--context` e `--namespace` podem
substituir os padrões atuais em um único comando.
