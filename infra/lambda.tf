# 1. IAM Role (A Identidade do Mensageiro)
resource "aws_iam_role" "lambda_exec" {
  name = "legal-orchestrator-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. Permissão para rodar dentro da VPC (Obrigatório para acessar RDS/Redis)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# 3. Zip do Código (Preparando a entrega)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${path.module}/lambda_function.zip"
}

# 4. A Função Lambda (O Mensageiro em si)
resource "aws_lambda_function" "orchestrator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "legal-ai-orchestrator"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.9"

  # Configuração de Rede: Colocando o mensageiro dentro da fortaleza
  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.db_sg.id]
  }

  environment {
    variables = {
      DB_HOST = aws_db_instance.legal_db.address # Conecta ao Guardião da Persistência[cite: 1]
    }
  }
}
