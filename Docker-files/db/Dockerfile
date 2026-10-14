FROM mysql:8.0.33
LABEL "Project"="Vprofile"
LABEL "Author"="Felipe"

# Para fins de estudo, mas como boa prática, recomenda-se utilizar --mount=type=secret.
# O --mount=type=secret monta o valor temporariamente durante o RUN, evitando que ele fique salvo em uma camada da imagem.
# Também é ideal utilizar valores/variáveis definidos no ambiente, por exemplo: GitHub Actions em produção -> MYSQL_PASSWORD.
# Quando combinado com id=db_password, o Docker BuildKit cria um diretório temporário para armazenar os secrets,
# e após a execução do comando RUN remove esse diretório, evitando que o valor fique persistido na imagem.
ENV MYSQL_ROOT_PASSWORD="vprodbpass"
ENV MYSQL_DATABASE="accounts"

ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql