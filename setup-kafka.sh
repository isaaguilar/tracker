#!/usr/bin/env bash
#
# Usage:
#   bash setup-kafka.sh server=user@192.168.1.200 brokers=1.2.3.4:9092
#
# Requirements:
#   SSH authorization keys must be set on server for unattended installation
set -x
set -euo pipefail
declare $@

kafka_server=${kafka_server:-$server}
kafka_advertised_listeners=${kafka_advertised_listeners:-$brokers}

compose_file=$(mktemp)

cat <<EOF > "$compose_file"
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - kafka-net

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    container_name: kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENERS: PLAINTEXT://:9092
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://$kafka_advertised_listeners
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    networks:
      - kafka-net

  proxy:
   image: haproxy:2.8
   container_name: haproxy
   volumes:
     - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
   ports:
     # HAProxy exposes 9093 to the host, which your NAT maps to 9092
     - "9093:9093"
   networks:
     - kafka-net

networks:
  kafka-net:
    driver: bridge
EOF

haproxy_cfg=$(mktemp)

cat <<'EOF' > "$haproxy_cfg"
global
    log stdout local0

defaults
    log global
    mode tcp
    timeout connect 10s
    timeout client 30s
    timeout server 30s

listen kafka-listener
    bind *:9093
    server kafka-broker kafka:9092
EOF

start_sh=$(mktemp)
cat <<'EOF' > "$start_sh"
cd $(dirname $0)
ls -lah 
docker-compose up -d
EOF


# Send these files to the kafka server
scp $compose_file $kafka_server:~/kafka/compose.yaml
scp $haproxy_cfg $kafka_server:~/kafka/haproxy.cfg
scp $start_sh $kafka_server:~/kafka/start.sh
ssh $kafka_server 'bash ~/kafka/start.sh'