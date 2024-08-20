#!/bin/bash

# Function to check if a service is activated
check_service() {
    local service_name=$1
    local check_command=$2

    # Execute the check command and get the output
    local output=$(eval "$check_command 2>/dev/null")
    
    # Check if the output contains any resources
    if [[ -n "$output" ]]; then
        echo "$service_name"
    fi
}

# Parse AWS profile argument
AWS_PROFILE="Ronan"
while getopts ":p:" opt; do
    case ${opt} in
        p )
            AWS_PROFILE="--profile $OPTARG"
            ;;
        \? )
            echo "Usage: cmd [-p profile]"
            exit 1
            ;;
    esac
done

# List of services and their corresponding check commands
services=(
    "EC2:aws ec2 describe-instances $AWS_PROFILE --query 'Reservations[*].Instances[*].InstanceId' --output text"
    "S3:aws s3api list-buckets $AWS_PROFILE --query 'Buckets[*].Name' --output text"
    "RDS:aws rds describe-db-instances $AWS_PROFILE --query 'DBInstances[*].DBInstanceIdentifier' --output text"
    "Lambda:aws lambda list-functions $AWS_PROFILE --query 'Functions[*].FunctionName' --output text"
    "DynamoDB:aws dynamodb list-tables $AWS_PROFILE --query 'TableNames[*]' --output text"
    "SNS:aws sns list-topics $AWS_PROFILE --query 'Topics[*].TopicArn' --output text"
    "SQS:aws sqs list-queues $AWS_PROFILE --query 'QueueUrls[*]' --output text"
    "CloudFormation:aws cloudformation list-stacks $AWS_PROFILE --query 'StackSummaries[*].StackName' --output text"
    "CloudWatch:aws cloudwatch describe-alarms $AWS_PROFILE --query 'MetricAlarms[*].AlarmName' --output text"
    "ECS:aws ecs list-clusters $AWS_PROFILE --query 'clusterArns[*]' --output text"
    "EKS:aws eks list-clusters $AWS_PROFILE --query 'clusters[*]' --output text"
    "IAM:aws iam list-users $AWS_PROFILE --query 'Users[*].UserName' --output text"
    "Kinesis:aws kinesis list-streams $AWS_PROFILE --query 'StreamNames[*]' --output text"
    "Redshift:aws redshift describe-clusters $AWS_PROFILE --query 'Clusters[*].ClusterIdentifier' --output text"
    "ElasticBeanstalk:aws elasticbeanstalk describe-environments $AWS_PROFILE --query 'Environments[*].EnvironmentName' --output text"
    "ElastiCache:aws elasticache describe-cache-clusters $AWS_PROFILE --query 'CacheClusters[*].CacheClusterId' --output text"
)

# Check each service
echo "Activated Services:"
for service in "${services[@]}"; do
    IFS=':' read -r service_name check_command <<< "$service"
    check_service "$service_name" "$check_command"
done