#!/bin/bash

# Acessa a pasta de infraestrutura
cd infra

# Remove todos os recursos provisionados no GCP/AWS
# Isso interrompe a cobrança de instâncias RDS e ElastiCache
terraform destroy -auto-approve

echo "Fortaleza Digital desativada com sucesso. Recursos removidos para evitar custos."