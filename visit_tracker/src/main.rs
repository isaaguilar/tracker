use aws_sdk_dynamodb::types::AttributeValue;
use aws_sdk_dynamodb::{Client as DynamoClient, Error as DynamoError};
use chrono::Utc;
use lambda_http::{Body, Error, Request, Response, run, service_fn};
#[cfg(target_arch = "x86_64")]
use rdkafka::{
    ClientConfig,
    producer::{BaseProducer, BaseRecord, FutureProducer, FutureRecord, Producer},
};
#[cfg(not(target_arch = "x86_64"))]
use rdkafka::{
    ClientConfig,
    producer::{BaseProducer, BaseRecord, FutureProducer, FutureRecord, Producer},
};
use serde::{Deserialize, Serialize};
use std::env;
use std::time::Duration;

#[derive(Deserialize, Serialize, Debug)]
struct ScoreEntry {
    name: String,
    score: u32,
    level: usize,
}

impl ScoreEntry {
    fn add(name: impl Into<String>, score: u32, level: usize) -> Self {
        Self {
            level: level,
            name: name.into(),
            score: score,
        }
    }
}

#[derive(Serialize, Debug)]
struct Output {
    leaderboard: Vec<ScoreEntry>,
}

async fn handler(event: Request) -> Result<Response<Body>, Error> {
    let brokers = env::var("KAFKA_BROKERS")?;
    let topic = env::var("KAFKA_TOPIC")?;
    let table_name = env::var("DYNAMODB_TABLE")?;

    let headers = event.headers();
    println!("Headers: {:?}", headers);
    let session_id = headers
        .get("x-session-id")
        .and_then(|value| value.to_str().ok())
        .unwrap_or("00000000-0000-0000-0000-000000000000")
        .to_string();

    let origin = headers
        .get("Origin")
        .and_then(|value| Some(value.to_str().ok()))
        .unwrap_or_default();

    produce(&brokers, &topic, &session_id).await;

    let config = aws_config::load_from_env().await;
    let client = DynamoClient::new(&config);

    // Insert score into DynamoDB
    let builder = client
        .put_item()
        .table_name(&table_name)
        .item("session_id", AttributeValue::S(session_id.clone()))
        .item(
            "datetime",
            AttributeValue::N(Utc::now().timestamp().to_string()),
        );

    let builder = match origin {
        Some(origin_value) => builder.item("origin", AttributeValue::S(origin_value.to_string())),
        None => builder,
    };

    builder.send().await?;

    // // Scan table
    // let result = client.scan().table_name(&table_name).send().await?;

    Ok(Response::builder()
        .status(200)
        .header("Content-Type", "application/json")
        .body(Body::Text(serde_json::json!({}).to_string()))
        .unwrap())
}

async fn produce(brokers: &str, topic_name: &str, uuid: &str) {
    let producer: &FutureProducer = &ClientConfig::new()
        .set("bootstrap.servers", brokers)
        .set("message.timeout.ms", "28000")
        .create()
        .expect("Producer creation error");

    let delivery_status = producer
        .send(
            FutureRecord::to(topic_name).payload(uuid).key(uuid),
            Duration::from_secs(0),
        )
        .await;

    println!(
        "Message {}, brokers: {}, topic: {}, completed: {:?}",
        uuid, brokers, topic_name, delivery_status
    );
}

#[tokio::main]
async fn main() {
    if let Err(e) = run(service_fn(handler)).await {
        eprintln!("Lambda runtime error: {:?}", e);
        std::process::exit(1);
    }
}
