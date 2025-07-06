# Prova DevOps RNP

Repositório contendo uma solução completa de monitoramento web, desenvolvida em containers Docker, com armazenamento em PostgreSQL e painel de visualização em Grafana.

## Visão Geral

Este projeto implementa um agente de monitoramento que executa, em intervalos regulares, testes de rede:

* **Ping**: mede latência (RTT) e perda de pacotes (%)
* **HTTP**: mede tempo de resposta e captura códigos de status (200, 404, etc.)

Os resultados são armazenados em um banco de dados PostgreSQL e exibidos em dashboards configuráveis no Grafana.

## Estrutura de Diretórios

```
prova-devops-rnp/
├── docker-compose.yml        # Orquestração dos serviços
├── db/
│   ├── Dockerfile            # Imagem customizada do Postgres
│   └── init.sql              # Script de criação de tabelas
├── agent/
│   ├── Dockerfile            # Imagem do agente Python
│   ├── requirements.txt      # Dependências Python
│   └── main.py               # Lógica de coleta e gravação de métricas
├── terraform/                # Infraestrutura como Código (Terraform)
│   ├── main.tf               # Definições de rede e containers Docker
│   ├── variables.tf          # Variáveis de configuração
   └── outputs.tf            # Saídas após o apply
└── .github/
    └── workflows/            # Workflows do GitHub Actions
        └── terraform.yml     # Pipeline CI/CD para Terraform
```

prova-devops-rnp/ ├── docker-compose.yml        # Orquestração dos serviços ├── db/ │   ├── Dockerfile            # Imagem customizada do Postgres │   └── init.sql              # Script de criação de tabelas └── agent/ ├── Dockerfile            # Imagem do agente Python ├── requirements.txt      # Dependências Python └── main.py               # Lógica de coleta e gravação de métricas

````

## Pré-requisitos

- Docker e Docker Compose instalados
- Porta **5433** (host) livre (ou ajuste no `docker-compose.yml`)
- Rede interna Docker para comunicação entre serviços

## Como Executar

No diretório raiz do projeto:

```
# Build e inicie os serviços em modo detached
docker-compose up -d --build

# Verifique status
docker-compose ps
````

* **DB** (Postgres): acessível via `localhost:5433` (host) ↔ `5432` (container)
* **Agent**: coleta métricas a cada 30s
* **Grafana**: interface web em `http://localhost:3000` (admin/admin)

## Configuração do Grafana

1. Acesse Grafana (`http://localhost:3000`, credenciais padrão `admin/admin`).
2. Navegue em **Configuration > Data Sources > Add data source > PostgreSQL**:

   * Host: `db:5432`
   * Database: `monitor_db`
   * User: `monitor`
   * Password: `monitor_pass`
   * SSL Mode: `disable`
3. Clique em **Save & Test** para verificar a conexão.

## Dashboards Sugeridos

1. **Ping RTT**

   ```sql
   SELECT $__time(timestamp), rtt_ms AS value, host AS metric
   FROM ping_results
   ```
2. **Ping Packet Loss**

   ```sql
   SELECT $__time(timestamp), packet_loss AS value, host AS metric
   FROM ping_results
   ```
3. **HTTP Response Time**

   ```sql
   SELECT $__time(timestamp), response_time_ms AS value, host AS metric
   FROM http_results
   ```
4. **HTTP Status Codes**

   ```sql
   SELECT status_code AS Status, COUNT(*) AS Count
   FROM http_results
   WHERE $__timeFilter(timestamp)
   GROUP BY status_code
   ORDER BY status_code
   ```

````

## Terraform IaC

O diretório **terraform/** contém todos os arquivos necessários para provisionar o ambiente de Docker via Terraform. Nele estão:

- **main.tf**: configura provider Docker, rede, volume e containers (Postgres, Agent e Grafana).
- **variables.tf**: define variáveis de entrada para personalização (usuário, senhas, portas, targets, etc.).
- **outputs.tf**: apresenta os IDs dos containers e a URL do Grafana após o provisionamento.

Para executar:
```
cd terraform
tf init
tf plan
tf apply -auto-approve
````

## CI/CD Pipeline

Este projeto utiliza GitHub Actions para automação de infraestrutura (Terraform) e integração contínua:

1. **fmt & validate**: formata (`terraform fmt`) e valida (`terraform validate`) os arquivos Terraform.
2. **plan**: gera o plano de execução (`terraform plan -out=tfplan`) e salva como artefato.
3. **apply (manual)**: permite aplicar o plano gerado (`terraform apply tfplan`) via botão "Run workflow".


Para usar:

* **CI**: ao dar push em `main`, o workflow roda fmt, validate e plan.
* **CD**: acesse Actions > Terraform CI/CD e clique em **Run workflow** para aplicar o plano.

Dessa forma temos integração e entrega contínua da infraestrutura declarada em Terraform.
