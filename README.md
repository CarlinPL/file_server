# File Server — IaC com Terraform + Ansible + GitHub Actions

Projeto pessoal de estudo de **Infraestrutura como Código (IaC)**. Ele sobe, na AWS, um servidor de arquivos (File Server) com pastas compartilhadas via protocolo **SMB (Samba)**, usando:

- **Terraform** → provisiona a infraestrutura (EC2, Security Group, IP Elástico)
- **Ansible** → configura o servidor (instala e configura o Samba, cria usuário e pastas)
- **GitHub Actions** → automatiza o deploy (CI/CD manual, via `workflow_dispatch`)

---

## Sumário

- [Arquitetura](#arquitetura)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Pré-requisitos](#pré-requisitos)
- [1. Configurar credenciais AWS](#1-configurar-credenciais-aws)
- [2. Provisionar infraestrutura com Terraform](#2-provisionar-infraestrutura-com-terraform)
- [3. Configurar o servidor com Ansible](#3-configurar-o-servidor-com-ansible)
- [4. Acessar as pastas compartilhadas (SMB)](#4-acessar-as-pastas-compartilhadas-smb)
- [Rodando via GitHub Actions (CI/CD)](#rodando-via-github-actions-cicd)
- [Variáveis que você pode customizar](#variáveis-que-você-pode-customizar)
- [Avisos importantes](#avisos-importantes)

---

## Arquitetura

```
GitHub Actions ──▶ Terraform ──▶ EC2 (Ubuntu) + Security Group + Elastic IP
                                        │
                                        ▼
                    Ansible (via inventário dinâmico aws_ec2) ──▶ Instala/configura Samba
                                        │
                                        ▼
                         Pastas compartilhadas via SMB (porta 445)
```

A EC2 é criada pelo Terraform já com um **Security Group** liberando as portas:
- `22` (SSH)
- `445` (SMB)

E recebe um **Elastic IP**, para o endereço público não mudar a cada `apply`.

## Estrutura do repositório

```
.
├── .github/workflows/
│   ├── terraform.yaml      # Workflow para terraform init/validate/plan/apply
│   └── ansible.yaml        # Workflow para rodar o playbook Ansible
├── terraform/
│   ├── main.tf              # Provider AWS + versão do Terraform
│   ├── provider.tf          # Região da AWS (sa-east-1)
│   ├── backend.tf           # State remoto em bucket S3
│   ├── variables.tf         # instance_type e key_name
│   ├── ec2.tf                # Instância EC2 do file server
│   ├── security_group.tf    # Regras de firewall (SSH e SMB)
│   ├── elastic_ip.tf        # IP público fixo
│   └── outputs.tf            # Exibe IP público/privado após o apply
└── ansible/
    ├── ansible.cfg
    ├── playbook.yml          # Define usuário Samba, senha e pastas a criar
    ├── inventory/aws_ec2.yml # Inventário dinâmico (busca a EC2 automaticamente na AWS)
    └── roles/samba/
        ├── tasks/main.yml    # Instala Samba, cria pastas, cria usuário, aplica config
        ├── handlers/main.yml # Reinicia o serviço smbd quando necessário
        └── templates/smb.conf.j2  # Template do smb.conf gerado dinamicamente
```

## Pré-requisitos

Antes de começar, tenha instalado/configurado:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) + coleção `amazon.aws` (`ansible-galaxy collection install amazon.aws`)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Uma conta AWS com permissões para criar EC2, Security Group e Elastic IP
- Um par de chaves (Key Pair) já criado na AWS (por padrão, o projeto espera uma chamada `pcgoku` — veja a seção de variáveis abaixo)
- Um bucket S3 já existente para o state do Terraform (o backend está configurado para o bucket `terraformgoku`, na região `sa-east-1`)

## 1. Configurar credenciais AWS

```bash
aws configure
```

Isso vai pedir sua **Access Key** e **Secret Access Key**, geradas em: AWS Console → IAM → Credenciais de Segurança → Chaves de Acesso.

## 2. Provisionar infraestrutura com Terraform

```bash
cd terraform
terraform init        # baixa os providers e configura o backend S3
terraform validate    # valida a sintaxe dos arquivos .tf
terraform plan         # mostra o que será criado/alterado
terraform apply        # cria a infraestrutura de fato
```

Ao final do `apply`, o Terraform mostra o **IP público** e o **IP privado** da instância criada (definidos em `outputs.tf`).

## 3. Configurar o servidor com Ansible

O Ansible usa um **inventário dinâmico** (`ansible/inventory/aws_ec2.yml`), ou seja, ele descobre sozinho a instância recém-criada na AWS — não é necessário editar IP manualmente. Por padrão ele busca instâncias em `sa-east-1` com estado `running` e assume:

- usuário SSH: `ubuntu`
- chave privada: `~/.ssh/pcgoku.pem`

Ajuste esses valores em `ansible/inventory/aws_ec2.yml` se sua chave tiver outro nome/caminho.

Depois, rode o playbook:

```bash
cd ansible
ansible-playbook -i inventory/aws_ec2.yml playbook.yml
```

Isso vai, na instância:
1. Atualizar os pacotes e instalar o Samba
2. Criar as pastas compartilhadas definidas em `playbook.yml` (por padrão: `teste1`, `teste2`, `teste3`)
3. Gerar o `smb.conf` a partir do template
4. Criar o usuário Linux/Samba (`fileserver`, senha padrão `teste123` — **troque isso**, veja avisos abaixo)
5. Reiniciar o serviço `smbd`

## 4. Acessar as pastas compartilhadas (SMB)

**Windows** — no Explorador de Arquivos:
```
\\IP_DA_INSTANCIA
```

**Linux** — no gerenciador de arquivos:
```
smb://IP_DA_INSTANCIA/NOME_DO_COMPARTILHAMENTO
```

Em ambos os casos, será solicitado usuário e senha — use as credenciais definidas em `ansible/playbook.yml` (`samba_user` / `samba_password`).

## Rodando via GitHub Actions (CI/CD)

O repositório tem dois workflows manuais (aba **Actions** → selecionar o workflow → **Run workflow**):

| Workflow | O que faz |
|---|---|
| `Terraform CI/CD` | Roda `init`, `validate` e `plan` sempre; roda `apply` só se você escolher `apply: true` no disparo manual |
| `Deploy Ansible` | Instala o Ansible, configura a chave SSH a partir do secret `EC2_SSH_PRIVATE_KEY`, testa a conexão e roda o playbook |

Para isso funcionar no seu fork/repositório, você precisa configurar:
- Um **IAM Role** na AWS para autenticação via OIDC (usado em `role-to-assume` nos workflows)
- O **secret** `EC2_SSH_PRIVATE_KEY` no repositório (Settings → Secrets and variables → Actions), contendo a chave privada `.pem` da instância

## Variáveis que você pode customizar

**Terraform** (`terraform/variables.tf`):
| Variável | Padrão | Descrição |
|---|---|---|
| `instance_type` | `t3.micro` | Tipo da instância EC2 |
| `key_name` | `pcgoku` | Nome do par de chaves AWS a usar |

**Ansible** (`ansible/playbook.yml`):
| Variável | Padrão | Descrição |
|---|---|---|
| `samba_user` | `fileserver` | Usuário criado no Linux e no Samba |
| `samba_password` | `teste123` | Senha do usuário (⚠️ troque em produção) |
| `shared_folders` | `teste1`, `teste2`, `teste3` | Lista de pastas a compartilhar |

## Avisos importantes

- ⚠️ A senha padrão do Samba (`teste123`) está hardcoded no playbook — isso é aceitável só para fins de estudo. Em qualquer uso real, use `ansible-vault` ou variáveis vindas de secrets.
- ⚠️ O Security Group libera as portas 22 e 445 para `0.0.0.0/0` (qualquer IP da internet). Para uso real, restrinja os `cidr_blocks` ao seu IP/rede.
- Este projeto é **educacional**, criado para praticar Terraform, Ansible e integração com GitHub Actions.