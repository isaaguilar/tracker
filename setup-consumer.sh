#!/usr/bin/env bash
#
# Usage:
#   bash setup-kafka.sh server=user@192.168.1.200 brokers=1.2.3.4:9092 topic=foo
#
# Requirements:
#   SSH authorization keys must be set on server for unattended installation
set -x
set -euo pipefail
declare $@

kafka_advertised_listeners=${kafka_advertised_listeners:-$brokers}
kafka_topic=${kafka_topic:-$topic}
kafka_group_id=${kafka_group_id:-$group_id}


docker_image_tar=$(mktemp)
docker build -q \
    -t kafka_consumer:latest \
    -f tracker_kafka_consumer/Dockerfile tracker_kafka_consumer
docker save -o "$docker_image_tar" kafka_consumer:latest

scp $docker_image_tar $server:~/consumer_image.tar
ssh $server 'docker load -i ~/consumer_image.tar'


compose_file=$(mktemp)

cat <<EOF > "$compose_file"
version: '3.8'

services:
  kafka_consumer:
    image: kafka_consumer:latest
    container_name: kafka_consumer_java
    ports:
      - "8080:8080"
    environment:
      KAFKA_TOPIC: $kafka_topic
      KAFKA_GROUP_ID: $kafka_group_id
      SPRING_KAFKA_BOOTSTRAP_SERVERS: $kafka_advertised_listeners
EOF

ssh $server 'mkdir -p ~/kafka/consumer'
scp $compose_file $server:~/kafka/consumer/compose.yaml
ssh $server 'bash -c "cd ~/kafka/consumer && docker-compose up -d"'