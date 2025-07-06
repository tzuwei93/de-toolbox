#!/bin/bash
set -e

# Set default environment variables
: "${SPARK_WAREHOUSE_DIR:=/tmp/spark-warehouse}"
: "${SPARK_THRIFT_PORT:=10000}"
: "${SPARK_DRIVER_MEMORY:=1g}"
: "${SPARK_EXECUTOR_MEMORY:=2g}"
: "${SPARK_DRIVER_CORES:=1}"
: "${SPARK_EXECUTOR_CORES:=1}"
: "${SPARK_NUM_EXECUTORS:=1}"
: "${AWS_ACCESS_KEY_ID:=NO_ACCESS_KEY_PROVIDED}"
: "${AWS_SECRET_ACCESS_KEY:=NO_SECRET_KEY_PROVIDED}"
: "${AWS_SESSION_TOKEN:=NO_SESSION_TOKEN_PROVIDED}"

echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
echo AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
echo AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION


# Create necessary directories
mkdir -p ${SPARK_WAREHOUSE_DIR}
mkdir -p /tmp/spark-events


# Start Spark Thrift Server in the background
echo "Starting Spark Thrift Server..."
nohup ${SPARK_HOME}/sbin/start-thriftserver.sh \
  --verbose \
  --jars ${SPARK_HOME}/jars/* \
  --master local[*] \
  --driver-memory ${SPARK_DRIVER_MEMORY} \
  --executor-memory ${SPARK_EXECUTOR_MEMORY} \
  --driver-cores ${SPARK_DRIVER_CORES} \
  --num-executors ${SPARK_NUM_EXECUTORS} \
  --executor-cores ${SPARK_EXECUTOR_CORES} \
  --conf spark.hadoop.fs.s3a.access.key=${AWS_ACCESS_KEY_ID} \
  --conf spark.hadoop.fs.s3a.secret.key=${AWS_SECRET_ACCESS_KEY} \
  --conf spark.hadoop.fs.s3a.session.token=${AWS_SESSION_TOKEN} \
  --conf spark.hadoop.fs.s3a.endpoint=https://s3.ap-northeast-1.amazonaws.com \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.hive.server2.thrift.port=${SPARK_THRIFT_PORT} \
  --conf spark.hadoop.hive.server2.thrift.bind.host=0.0.0.0 \
  --conf spark.hadoop.hive.server2.enable.doAs=false \
  --conf spark.hadoop.hive.metastore.schema.verification=false \
  --conf spark.hadoop.hive.server2.transport.mode=binary \
  --conf spark.hadoop.hive.server2.authentication=NOSASL \
  --conf spark.eventLog.enabled=false \
  --conf spark.eventLog.dir=file:///tmp/spark-events \
  --conf spark.history.fs.logDirectory=file:///tmp/spark-events \
  --hiveconf hive.metastore.warehouse.dir=${SPARK_WAREHOUSE_DIR} \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.sql.extensions=org.apache.spark.sql.hudi.HoodieSparkSessionExtension \
  --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.hudi.catalog.HoodieCatalog \
  > /tmp/spark-thrift.log 2>&1 &

# Wait for Thrift Server to start
MAX_RETRIES=30
ATTEMPT=1

# Simple log function with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Waiting for Spark Thrift Server on port ${SPARK_THRIFT_PORT}..."

# Function to check if server is running
check_server_running() {
  if nc -z localhost ${SPARK_THRIFT_PORT}; then
    return 0
  else
    return 1
  fi
}

# Wait for server to start
while [ $ATTEMPT -le $MAX_RETRIES ]; do
  if check_server_running; then
    log "Spark Thrift Server is running on port ${SPARK_THRIFT_PORT}"
    log "Spark Thrift Server is ready"
    break
  fi
  
  log "Attempt ${ATTEMPT}/${MAX_RETRIES}: Spark Thrift Server not ready yet..."
  ATTEMPT=$((ATTEMPT + 1))
  sleep 10
  
  if [ $ATTEMPT -gt $MAX_RETRIES ]; then
    log "Failed to start Spark Thrift Server after ${MAX_RETRIES} attempts. Logs:"
    cat /tmp/spark-thrift.log || true
    cat /tmp/spark-logs/* 2>/dev/null || true
    exit 1
  fi
done

# Keep container running and monitor the server
log "Monitoring Spark Thrift Server..."
while true; do
  if ! check_server_running; then
    log "Error: Spark Thrift Server is no longer running!"
    exit 1
  fi
  sleep 30
done
