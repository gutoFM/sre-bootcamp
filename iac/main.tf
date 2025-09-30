provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sre_api" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 22.04 (us-east-1)
  instance_type = "t2.micro"

  tags = {
    Name = "sre-bootcamp-api"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3-pip
              pip3 install flask prometheus_client
              cd /home/ubuntu
              cat <<EOPY > app.py
              from flask import Flask
              from prometheus_client import Counter, generate_latest
              app = Flask(__name__)
              REQUESTS = Counter('http_requests_total', 'Total requests', ['endpoint', 'status'])
              @app.route('/health')
              def health():
                  REQUESTS.labels(endpoint="/health", status="200").inc()
                  return "OK", 200
              @app.route('/hello')
              def hello():
                  REQUESTS.labels(endpoint="/hello", status="200").inc()
                  return "Serviço funcionando!", 200
              @app.route('/metrics')
              def metrics():
                  return generate_latest(), 200
              if __name__ == "__main__":
                  app.run(host="0.0.0.0", port=5000)
              EOPY
              nohup python3 app.py &
              EOF
}