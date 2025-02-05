#!/bin/bash

# AWS EC2에서 실행하는 스크립트
DOCKER_IMAGE="rsw2/elk-stack:latest"
CONTAINER_NAME="elk-stack"
EC2_COMPOSE_DIR="$(pwd)/elastic"

# Docker Hub 로그인 정보 설정
export DOCKER_ID=''
export DOCKER_PASSWORD=''

echo "🔄 AWS EC2에서 ELK Stack 배포 시작..."

# 1️⃣ Docker Hub 로그인
echo "🔐 Docker Hub 로그인 중..."
echo $DOCKER_PASSWORD | sudo docker login -u $DOCKER_ID --password-stdin

# 2️⃣ 기존 컨테이너 중지 및 제거
if [ "$(sudo docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 기존 ELK Stack 컨테이너 중지 중..."
    sudo docker stop $CONTAINER_NAME
    sudo docker rm $CONTAINER_NAME
fi

# 3️⃣ 최신 ELK Stack 이미지 가져오기
echo "📥 최신 ELK Stack 이미지 가져오는 중..."
sudo docker pull $DOCKER_IMAGE

# 4️⃣ 새로운 컨테이너 실행 (docker-compose 파일 포함)
echo "🚀 ELK Stack 컨테이너 실행 중..."
sudo docker run -d --name $CONTAINER_NAME \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $EC2_COMPOSE_DIR:/usr/share/elastic \
    $DOCKER_IMAGE

# 5️⃣ Docker Compose 실행 (컨테이너 내부 파일 사용)
echo "⚡ Docker Compose 실행 (EC2에서 실행)..."
sudo docker exec $CONTAINER_NAME docker-compose -f /usr/share/elastic/docker-compose.yml up -d

# 6️⃣ Elasticsearch 실행 대기
echo "⏳ Elasticsearch가 준비될 때까지 대기 중..."
until curl -s --cacert $EC2_COMPOSE_DIR/config/certs/ca/ca.crt -u elastic:changeme https://localhost:9200 | grep -q "missing authentication credentials"; do
    echo "❌ Elasticsearch가 아직 준비되지 않았습니다. 10초 후 다시 시도..."
    sleep 10
done

echo "✅ Elasticsearch 준비 완료!"

# 7️⃣ Elasticsearch 인증서 복사
echo "📂 Elasticsearch 인증서 복사 중..."
sudo cp $EC2_COMPOSE_DIR/config/certs/ca/ca.crt $EC2_COMPOSE_DIR/ca.crt

# 8️⃣ Elasticsearch 설정 적용
echo "🔧 Kibana 시스템 사용자 비밀번호 설정 중..."
curl -X POST --cacert $EC2_COMPOSE_DIR/ca.crt -u "elastic:changeme" -H "Content-Type: application/json" \
    https://localhost:9200/_security/user/kibana_system/_password -d '{"password":"changeme"}'

echo "✅ Elasticsearch 설정 완료!"

# 9️⃣ 실행 상태 확인
echo "🔍 ELK Stack 로그 확인..."
sudo docker logs -f $CONTAINER_NAME
