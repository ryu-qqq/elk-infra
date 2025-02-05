# Elastic Stack Docker Compose

## 개요
이 프로젝트는 Elastic Stack (Elasticsearch, Kibana, Logstash, Filebeat, Metricbeat)을 Docker Compose를 이용하여 실행할 수 있도록 구성된 환경입니다. ELK 스택을 활용하여 로그 수집, 분석, 시각화를 수행할 수 있습니다.

## 프로젝트 구조

```
.
├── docker-compose.yml    # Elastic Stack 서비스 정의
├── .env                  # 환경 변수 파일
├── logstash.conf         # Logstash 파이프라인 설정
├── filebeat.yml          # Filebeat 설정 파일
├── metricbeat.yml        # Metricbeat 설정 파일
├── logstash_ingest_data/ # Logstash Ingest 데이터 폴더
└── filebeat_ingest_data/ # Filebeat Ingest 데이터 폴더
```

## 서비스 구성

### 1. setup (초기 설정 컨테이너)
- Elasticsearch 및 Kibana의 초기 설정을 수행합니다.
- 인증서를 생성하여 TLS 보안을 설정합니다.
- `ELASTIC_PASSWORD`, `KIBANA_PASSWORD` 환경 변수를 사용하여 보안 계정을 설정합니다.
- Elasticsearch가 시작될 때까지 대기 후 Kibana의 시스템 계정 비밀번호를 설정합니다.

### 2. es01 (Elasticsearch)
- 기본적인 Elasticsearch 노드로, `single-node` 모드로 실행됩니다.
- `xpack.security.enabled=true`를 설정하여 보안을 활성화합니다.
- TLS를 활성화하여 보안 통신을 수행합니다.
- 데이터를 저장하기 위한 `esdata01` 볼륨을 사용합니다.

### 3. kibana (데이터 시각화)
- Kibana를 실행하여 Elasticsearch 데이터를 시각화할 수 있도록 합니다.
- Elasticsearch와 TLS를 통해 연결됩니다.
- 기본 포트 `5601`에서 실행됩니다.

### 4. logstash (데이터 처리)
- Logstash는 데이터 파이프라인을 처리하며, `logstash.conf` 설정을 기반으로 동작합니다.
- `ELASTIC_HOSTS` 환경 변수를 사용하여 Elasticsearch와 연동됩니다.
- `logstash_ingest_data` 폴더를 통해 Ingest 데이터를 처리할 수 있습니다.

### 5. filebeat (로그 수집)
- Filebeat는 컨테이너 내부의 로그를 수집하여 Logstash 또는 Elasticsearch로 전송합니다.
- `filebeat.yml` 설정 파일을 사용합니다.
- Docker 컨테이너의 로그를 `/var/lib/docker/containers` 경로에서 읽습니다.

### 6. metricbeat (메트릭 수집)
- Metricbeat는 컨테이너의 시스템 메트릭을 수집합니다.
- `metricbeat.yml` 설정 파일을 사용합니다.
- CPU, 메모리, 파일 시스템 사용량 등의 데이터를 수집합니다.

## 환경 변수
`.env` 파일을 사용하여 설정 값을 관리할 수 있습니다.

```
ELASTIC_PASSWORD=changeme
KIBANA_PASSWORD=changeme
STACK_VERSION=8.16.2
CLUSTER_NAME=docker-cluster
LICENSE=basic
ES_PORT=9200
KIBANA_PORT=5601
ES_MEM_LIMIT=1073741824
KB_MEM_LIMIT=1073741824
LS_MEM_LIMIT=1073741824
ENCRYPTION_KEY=566c32b3a14956121ff2170e5030b471551370178f43e5626eec58b04a30fae2
```


## 실행 방법
```
docker-compose up -d
```


### 참고 
 - https://www.elastic.co/kr/blog/getting-started-with-the-elastic-stack-and-docker-compose
