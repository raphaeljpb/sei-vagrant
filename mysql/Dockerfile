############################################################
# Dockerfile de construção do container do MySQL 
# utilizado pelo SEI e pelo SIP
#
# Baseado no CentOS 6.X
############################################################

# Definição da imagem de base para o CentOS 6.X
FROM centos:centos6

# Autor e mantenedor do container
MAINTAINER PEN - Processo Eletrônico Nacional

# Atualização dos componentes utilizados na instalação
RUN yum -y update mysql-server-5.* unzip

# Cópia dos backups dos bancos de dados do SEI e SIP
ADD .tmp/sei_mysql.sql /tmp/sei_mysql.sql
ADD .tmp/sip_mysql.sql /tmp/sip_mysql.sql
	
################## INICIO DA INSTALACAO ######################
# Instalação do MySQL seguindo as recomendações descritas na documentação do SEI
# Ref: http://sei.processoeletronico.gov.br/wiki/manual_de_instalacao#<SESSAO DE INSTALAÇÃO DO MYSQL>

# Instalação do MySQL Server 5.X
RUN yum install -y mysql-server-5.*

# Configuração da estrutura inicial do banco de dados
RUN mysql_install_db

# Criação dos bancos de dados do sistema
RUN service mysqld start && \
    mysqladmin create sip && \
    mysqladmin create sei

# Criação dos usuários utilizados na conexão com SEI e SIP 
RUN service mysqld start && \
    mysql -e "CREATE USER 'sip_user'@'%' IDENTIFIED BY 'sip_user'" sip && \
    mysql -e "CREATE USER 'sei_user'@'%' IDENTIFIED BY 'sei_user'" sei && \
    mysql -e "GRANT ALL PRIVILEGES ON sip.* TO 'sip_user'@'%'" sip && \
    mysql -e "GRANT ALL PRIVILEGES ON sei.* TO 'sei_user'@'%'" sei 

# Restauração dos bancos de dados
RUN service mysqld start && cd /tmp && \
    mysql sei < sei_mysql.sql && \
    mysql sip < sip_mysql.sql && \
    rm /tmp/sei_mysql.sql /tmp/sip_mysql.sql

# Atualização dos parâmetros do SEI e do SIP
RUN service mysqld start && \
    mysql -e "update orgao set sigla='ABC', descricao='ORGAO ABC' where id_orgao=0;" sip && \
    mysql -e "update sistema set pagina_inicial='http://localhost/sip' where sigla='SIP';" sip && \ 
    mysql -e "update sistema set pagina_inicial='http://localhost/sei/inicializar.php', web_service='http://localhost/sei/controlador_ws.php?servico=sip' where sigla='SEI';" sip && \
    mysql -e "update orgao set sigla='ABC', descricao='ORGAO ABC' where id_orgao=0;" sei

# Temp: Remove registros de auditoria presentes na base de referência
RUN service mysqld start && \
    mysql -e "delete from auditoria_protocolo;" sei

# Configuração para utilizar autenticação nativa do SEI/SIP
RUN service mysqld start && \
    mysql -e "update orgao set sin_autenticar='N' where id_orgao=0;" sip

# Alteração das configurações padrões do MySQL
RUN service mysqld start && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;"

##################### FIM DA INSTALACAO #####################

# Exposição da porta de conexão ao MySQL Server
EXPOSE 3306

# Inicialização do serviço 
CMD ["/usr/bin/mysqld_safe", "--bind-address=0.0.0.0"]