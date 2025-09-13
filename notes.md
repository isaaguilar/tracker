# Notes

Create the topic:

```bash
kafka-topics --bootstrap-server kafka:9092 --create --topic exampleTopic --partitions 1 --replication-factor 1
```

In one terminal, start a producer:

```bash
kafka-console-producer --bootstrap-server kafka:9092 --topic exampleTopic
```

Write something in the open producer

```bash
> hello, i'm writing a message
```

In another teminal, start a consumer:

```bash
kafka-console-consumer --bootstrap-server kafka:9092 --topic exampleTopic --from-beginning
```

Done.

