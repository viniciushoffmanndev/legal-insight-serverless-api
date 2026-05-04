# 1. Criação da API Gateway (O Ponto de Entrada)
resource "aws_apigatewayv2_api" "legal_api" {
  name          = "legal-insight-gateway"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"] # Em produção, substitua pelo domínio do seu frontend
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# 2. Estágio da API (Onde ela "vive", ex: /prod)
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.legal_api.id
  name        = "prod"
  auto_deploy = True
}

# 3. Integração: Conecta a API com a sua Função Lambda
resource "aws_apigatewayv2_integration" "lambda_int" {
  api_id           = aws_apigatewayv2_api.legal_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.orchestrator.invoke_arn
}

# 4. Rota: Define o caminho (ex: /orchestrator)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.legal_api.id
  route_key = "ANY /orchestrator"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_int.id}"
}

# 5. Permissão: Permite que a API Gateway "chame" o Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orchestrator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.legal_api.execution_arn}/*/*"
}

# 6. Output: Exibe a URL final no terminal para você copiar
output "api_endpoint" {
  value = "${aws_apigatewayv2_stage.prod.invoke_url}/orchestrator"
}
