package com.isaaguilar.java.kafka_consumer.kafka;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumer {

    private static final Logger LOGGER = LoggerFactory.getLogger(KafkaConsumer.class);

    @KafkaListener(topics = "${KAFKA_TOPIC}", groupId = "${KAFKA_GROUP_ID}")
    public void consume(String message) {
        LOGGER.info(String.format("Message read: %s", message));
    }

}
