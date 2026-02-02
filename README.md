# Projeto IaC com Terraform

Este repositório contém a infraestrutura como código (IaC) usando **Terraform** para provisionar recursos na nuvem.

## Objetivo

Automatizar a criação de um File Server na nuvem, usando protocolo SMB(SAMBA) para compartilhamento de pastas em rede

## Infraestrutura provisionada

- Security Groups
- Instâncias EC2
- Usuário Samba
- Pastas Definidas no playbook

##  Tecnologias utilizadas

- Terraform
- Ansible
- AWS
- Git & GitHub

##  Pré-requisitos

Antes de começar, você precisa ter instalado:

- Terraform
- AWS CLI configurado
- Conta na AWS
- Ansible
- IDE de sua preferência

## Configuração

Configure suas credenciais AWS:

```bash
aws configure ## Ao rodar esse comando Irá pedir a chave de acesso gerada no console AWS em IAM > Credenciais de Segurança > Chaves de Acesso > Criar Chave de Acesso > Chave de Acesso secreta. Basta colar a Chave secreta e colar no terminal que seu AWS estará configurado.

```

## Usando Terraform

No terminal Dentro do Diretório terraform rodar o comando
```bash
terraform init
```
Isso faz com que o terraform inicie

Após isso vamos validar os arquivos terraform
```bash
terraform validate
```

Podemos ver o plano de execução para verificar quais mudanças serão feitas
```bash
terraform plan
```

Se não houver erros podemos partir para a ação rodando
```bash
terraform apply
```

Se tudo estiver configurado corretamente o código irá rodar sem nenhum problema e subir a instância na AWS EC2

## Usando Ansible

Após executar o código Terraform, será retornado para nós no terminal o IP Publico e IP privado da instância

Com isso precisamos ir ao código ansible e alterar o ip publico da instancia em inventory > hosts.ini
```bash
ip_publico_da_instancia ansible_user=ubuntu ansible_ssh_private_key_file=/home/user/nome_chave_ssh
```

Com isso já conseguimos rodar a parte de configuração do Ansible com o comando
```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

Se tudo der certo o Ansible vai configurar o usuário e senha do Samba e do Linux e também os nomes das pastas setados em Ansible > playbook.yml

## Como acessar as pastas compartilhadas com o protocolo samba

No explorador de arquivos do windows basta digitar
```bash
\\IP_DA_INSTANCIA
```
Irá abrir uma tela pedindo o usuário e senha, basta apenas digitar o usuário e senha setados no código que já terás acesso as pastas criadas.

No linux basta digitar no explorador de arquivos
```bash
smb://IP_DA_INSTANCIA/NOME_DO_COMPARTILHAMENTO
```
Após isso também digitar usuário e senha.








