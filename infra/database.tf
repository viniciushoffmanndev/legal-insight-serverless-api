# 1. DB Subnet Group (RDS)
# Define em quais subnets o banco de dados pode existir.
# Isso garante que o RDS fique dentro de uma rede controlada (VPC),
# normalmente em subnets privadas (sem acesso direto da internet).
# Ter mais de uma subnet (em AZs diferentes) permite alta disponibilidade
# caso você ative recursos como Multi-AZ no futuro.
resource "aws_db_subnet_group" "legal_db_subnet" {
  name = "legal-insight-db-subnet"


  # Subnets privadas onde o banco será provisionado.
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "Legal Insight DB Subnet Group"
  }
}

# 2. RDS PostgreSQL (Persistência)
# Cria a instância do banco de dados PostgreSQL gerenciado pela AWS.
# Esse banco será usado para persistência dos dados da aplicação.
# Ele fica dentro do DB Subnet Group (ou seja, dentro da VPC),
# aumentando a segurança e isolamento.
resource "aws_db_instance" "legal_db" {

  # Quantidade de armazenamento (em GB)
  allocated_storage = 20

  # Engine do banco
  engine         = "postgres"
  engine_version = "15"

  # Tipo da instância (define CPU/memória)
  # t3.micro é elegível ao free tier (bom para estudos/dev)
  instance_class = "db.t3.micro"

  # Nome do banco que será criado automaticamente
  db_name = "legalinsightdb"

  # Credenciais de acesso ao banco
  # ⚠️ Em produção, isso NÃO deve ficar no código
  # O ideal é usar AWS Secrets Manager
  username = "adminuser"
  password = "mudar_senha_depois_123"

  # Grupo de parâmetros padrão do PostgreSQL
  parameter_group_name = "default.postgres15"

  # Define se será criado snapshot final ao destruir o recurso
  # true = NÃO cria snapshot (mais rápido, porém arriscado)
  # false = cria backup antes de deletar (recomendado em produção)
  skip_final_snapshot = true

  # Associa o banco ao subnet group (define onde ele será criado na rede)
  db_subnet_group_name = aws_db_subnet_group.legal_db_subnet.name

  tags = {
    Name = "LegalInsight-Postgres"
  }
}

# 3. Redis Subnet Group (ElastiCache)
# Define em quais subnets o Redis pode existir.
# Assim como o RDS, isso mantém o cache dentro da VPC.
# ⚠️ Aqui está usando apenas UMA subnet:
# Isso significa que NÃO há alta disponibilidade.
# Se essa subnet/AZ falhar, o Redis fica indisponível.
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = "legal-redis-subnet"

  subnet_ids = [
    aws_subnet.private_1.id
  ]

  tags = {
    Name = "Legal Insight Redis Subnet Group"
  }
}

# 4. Cluster Redis (Cache)
# Cria um cluster Redis gerenciado pela AWS (ElastiCache).
# Esse serviço é usado para:
# - cache de dados
# - sessões
# - otimização de performance da aplicação
# Diferente do banco (RDS), o Redis não é persistente por padrão,
# sendo usado para dados temporários e rápidos.
resource "aws_elasticache_cluster" "legal_redis" {

  # Nome único do cluster
  cluster_id = "legal-insight-cache"

  # Engine de cache
  engine = "redis"

  # Tipo da instância (CPU/memória)
  node_type = "cache.t3.micro"

  # Quantidade de nós no cluster
  # 1 = sem redundância / sem failover
  num_cache_nodes = 1

  # Grupo de parâmetros padrão do Redis
  parameter_group_name = "default.redis7"

  # Porta padrão do Redis
  port = 6379

  # Associa o Redis ao subnet group (define onde ele será criado na rede)
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name

  tags = {
    Name = "LegalInsight-Redis"
  }
}


