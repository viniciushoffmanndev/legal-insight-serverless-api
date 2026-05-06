# 1. Criar o Bucket S3 para o Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "legal-insight-frontend-${random_id.bucket_suffix.hex}" # Nome único
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. Configurar o Bucket para Static Website Hosting
resource "aws_s3_bucket_website_configuration" "frontend_config" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 3. Remover bloqueios de acesso público (Necessário para sites estáticos)
resource "aws_s3_bucket_public_access_block" "frontend_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Política para permitir leitura pública dos arquivos
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.frontend_access]
}

# Output para você saber qual URL acessar
output "frontend_url" {
  value = aws_s3_bucket_website_configuration.frontend_config.website_endpoint
}

# Faz o upload automático do index.html sempre que o arquivo mudar
resource "aws_s3_object" "frontend_index" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "../frontend/index.html" # Caminho para o seu arquivo
  content_type = "text/html"
  etag         = filemd5("../frontend/index.html") # Garante que o upload ocorra se o arquivo mudar
}
