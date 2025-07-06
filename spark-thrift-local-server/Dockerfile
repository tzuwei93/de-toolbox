# Use a base image with Java and Python
FROM amazoncorretto:11 AS base

# Set environment variables
ENV SPARK_HOME=/opt/spark \
    JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto \
    HADOOP_HOME=/opt/hadoop \
    PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HADOOP_HOME/bin:$JAVA_HOME/bin \
    SPARK_VERSION=3.5.0 \
    HADOOP_VERSION=3 \
    LD_LIBRARY_PATH=/var/lang/lib:$LD_LIBRARY_PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN yum update -y && \
    yum install -y \
        wget \
        tar \
        gzip \
        procps \
        python3 \
        python3-pip \
        python3-devel \
        gcc-c++ \
        openssl-devel \
        cyrus-sasl-devel \
        krb5-workstation \
        krb5-libs \
        netcat-openbsd \
        nc && \
    yum clean all && \
    rm -rf /var/cache/yum

# Install Spark
RUN mkdir -p /opt && \
    cd /tmp && \
    # Try multiple mirrors if download fails
    (wget -q --tries=3 --timeout=30 https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz || \
     wget -q --tries=3 --timeout=30 https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz || \
     wget -q --tries=3 --timeout=30 https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz) && \
    tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt/ && \
    ln -sf /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME && \
    # Verify Spark installation
    test -d $SPARK_HOME/bin && \
    rm -f /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# Create a layer for downloading JARs
FROM base AS jar-downloader

# Download all required JARs in a single layer
RUN mkdir -p /opt/spark/jars && \
    cd /opt/spark/jars && \
    # Function to download with retries
    download_with_retry() { \
        local url="$1" \
              filename="${1##*/}" \
              max_attempts=3 \
              attempt=1; \
        while [ $attempt -le $max_attempts ]; do \
            echo "Downloading $filename (attempt $attempt/$max_attempts)..."; \
            if wget -q "$url"; then \
                echo "Successfully downloaded $filename"; \
                return 0; \
            fi; \
            echo "Failed to download $filename, retrying..."; \
            sleep 2; \
            attempt=$((attempt + 1)); \
        done; \
        echo "Failed to download $filename after $max_attempts attempts"; \
        return 1; \
    } && \
    # Download Spark and Hive core JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/spark/spark-sql_2.12/3.5.0/spark-sql_2.12-3.5.0.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/spark/spark-hive_2.12/3.5.0/spark-hive_2.12-3.5.0.jar && \
    \
    # Hive JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-common/2.3.9/hive-common-2.3.9.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-exec/2.3.9/hive-exec-2.3.9-core.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-metastore/2.3.9/hive-metastore-2.3.9.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-serde/2.3.9/hive-serde-2.3.9.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-shims/2.3.9/hive-shims-2.3.9.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-llap-common/2.3.9/hive-llap-common-2.3.9.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hive/hive-llap-client/2.3.9/hive-llap-client-2.3.9.jar && \
    \
    # Avro JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.2/avro-1.11.2.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/avro/avro-mapred/1.11.2/avro-mapred-1.11.2.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/avro/avro-ipc/1.11.2/avro-ipc-1.11.2.jar && \
    \
    # Hadoop JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-runtime/3.3.4/hadoop-client-runtime-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client-api/3.3.4/hadoop-client-api-3.3.4.jar && \
    \
    # Thrift JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/thrift/libthrift/0.12.0/libthrift-0.12.0.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/thrift/libfb303/0.9.3/libfb303-0.9.3.jar && \
    \
    # Commons JARs
    download_with_retry https://repo1.maven.org/maven2/commons-codec/commons-codec/1.16.0/commons-codec-1.16.0.jar && \
    download_with_retry https://repo1.maven.org/maven2/commons-cli/commons-cli/1.5.0/commons-cli-1.5.0.jar && \
    \
    # AWS and S3 JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.4/hadoop-mapreduce-client-core-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.4/hadoop-auth-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-annotations/3.3.4/hadoop-annotations-3.3.4.jar && \
    download_with_retry https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client/3.3.4/hadoop-client-3.3.4.jar && \
    \
    # Hudi JARs
    download_with_retry https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark3.5-bundle_2.12/1.0.2/hudi-spark3.5-bundle_2.12-1.0.2.jar && \
    # Clean up any partial downloads
    find . -type f -name '*.jar.*' -delete


# Final image
FROM base

# Copy JARs from the jar-downloader stage
COPY --from=jar-downloader /opt/spark/jars/ ${SPARK_HOME}/jars/

# Create necessary directories with proper permissions
RUN mkdir -p /tmp/spark-events /tmp/derby /tmp/spark-logs && \
    chmod -R 777 /tmp/spark-events /tmp/derby /tmp/spark-logs

# Copy configuration files
# COPY start-spark-thrift.sh /usr/local/bin/

# Make the startup script executable
# RUN chmod +x /usr/local/bin/start-spark-thrift.sh

# Expose Thrift Server port
EXPOSE 10000 4040

# Set the entrypoint to our startup script
ENTRYPOINT ["/usr/local/bin/start-spark-thrift.sh"]

# Default command (can be overridden)
CMD []
