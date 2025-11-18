#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

RABBITMQ_VERSION="3.13-management"

apt-get update -y
apt-get install -y awscli ca-certificates curl gnupg lsb-release jq xfsprogs

TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PHOST=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-hostname)

get_secret () {
  value=$(aws secretsmanager get-secret-value --secret-id "$1" \
  --query 'SecretString' --output text --region us-east-1 || echo "ERROR")
  if [ "$value" = "ERROR" ]; then
    echo "Failed to retrieve secret: $1" >&2
    exit 1
  fi
  echo "$value"
}

ADMIN_USER=$(get_secret "rabbit_admin_user1")
ADMIN_PASS=$(get_secret "rabbit_admin_pass1")
ERLANG_COOKIE=$(get_secret "rabbit_erlang_cookie1")

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker && systemctl start docker

mkdir -p /var/lib/rabbitmq
chmod 777 /var/lib/rabbitmq

docker run -d --name rabbitmq \
  -h ${PHOST} \
  -e RABBITMQ_ERLANG_COOKIE="${ERLANG_COOKIE}" \
  -e RABBITMQ_DEFAULT_USER="${ADMIN_USER}" \
  -e RABBITMQ_DEFAULT_PASS="${ADMIN_PASS}" \
  -e RABBITMQ_USE_LONGNAME=true \
  -e RABBITMQ_NODENAME="rabbit@${PHOST}" \
  -p 5672:5672 -p 15672:15672 -p 4369:4369 -p 25672:25672 \
  -v /var/lib/rabbitmq:/var/lib/rabbitmq \
  --restart unless-stopped \
  rabbitmq:${RABBITMQ_VERSION}

# Wait for RabbitMQ to be ready
echo "Waiting for RabbitMQ to start..."
for i in {1..30}; do
  if docker exec rabbitmq rabbitmqctl status >/dev/null 2>&1; then
    echo "RabbitMQ is ready!"
    break
  fi
  echo "Waiting for RabbitMQ... attempt $i/30"
  sleep 10
done

# Enable plugins without interactive flags
docker exec rabbitmq rabbitmq-plugins enable rabbitmq_peer_discovery_aws

# Verify management UI is accessible
echo "Waiting for management UI to be ready..."
for i in {1..30}; do
  if curl -f -u "${ADMIN_USER}:${ADMIN_PASS}" http://localhost:15672/api/overview >/dev/null 2>&1; then
    echo "Management UI is ready!"
    break
  fi
  echo "Waiting for management UI... attempt $i/30"
  sleep 5
done
