import json
import os

def lambda_handler(event, context):
    # O mensageiro recebe o pedido (event)
    print("Mensageiro Legal AI Orchestrator convocado!")
    
    # Simulação de busca de dados no RDS/Redis
    db_host = os.environ.get('DB_HOST', 'localhost')
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Mensagem entregue com sucesso!',
            'target_db': db_host,
            'status': 'Protegido pela VPC'
        })
    }