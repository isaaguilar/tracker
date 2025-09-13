# Project Tracker

This is a learning project to:

- Set up a single node kafka
- Connect a producer to kafka
- Set up DRY terraform modules to recycle in future projects
- Expose a lambda function to track sessions on webpage

TODO

- Connect a consumer to kafka
- Add automation for the tf builds, cargo builds, and kafka server setup via GHA


## Setup Instructions

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (if deploying to AWS)
- SSH access to your Kafka server


### 1. Kafka Setup

Edit and run the Kafka setup script:

```sh
bash setup-kafka.sh server=user@<KAFKA_SERVER_IP> brokers=<BROKER_IP>:9092
```

This will:
- Copy Docker Compose and HAProxy configs to your Kafka server
- Start Zookeeper, Kafka, and HAProxy via Docker Compose

### 2. Configuration

- Place your environment-specific `.tfvars` and `.key` files in `terraform/environments/dynamodb/` and `terraform/environments/lambda/`.


### 3. DynamoDB Deployment

```sh
cd terraform/deploy
bash dynamodb.sh
```

This will:
- Initialize Terraform for DynamoDB
- Plan and apply the infrastructure using your environment configs

### 4. Lambda Deployment

```sh
cd terraform/deploy
bash lambda.sh
```

This will:
- Build the Lambda zip package
- Initialize Terraform for Lambda
- Plan and apply the infrastructure using your environment configs

### 6. Additional Notes

- Make sure your AWS credentials are configured if deploying to AWS.
- For troubleshooting, check the output of each script and Terraform logs.

## License

See [LICENSE](LICENSE) for details.