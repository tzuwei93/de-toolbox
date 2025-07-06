# Spark Thrift Local Server for local development

This directory contains the Docker configuration for running a local Spark Thrift Server with limited resources suitable for development. The container is configured to run with minimal resource allocation by default (2GB RAM, 1 CPU cores) to ensure it works well on local machines. You can adjust the resource allocation by setting the environment variables in the docker run command. **And it also have a tutorial for querying a hudi table located in S3 without predefined meta store.**

The Dockerfile builds a Spark Thrift Server container using a multi-stage approach for efficiency, starting with an amazoncorretto:11 base and installing essential dependencies. It features a dedicated stage for downloading and managing JAR files (Spark, Hive, Avro, AWS SDK) to **optimize the image building process**, while setting up necessary environment variables, file permissions, and exposing ports 10000 (Thrift Server) and 4040 (Spark UI). The configuration includes a custom startup script for launching the Spark Thrift Server with proper settings.

Dependencies:
- Spark Version: 3.5.0
- Hadoop Version: 3
- Hive Version: 2.3.9
- Hudi Version: 1.0.2
- Docker Version: Latest

## Environment Variables

### Spark Configuration

  FYI: In Dockerfile, you can COPY spark-defaults.conf to $SPARK_HOME/conf/ if is fixed or just modify the core arguments in start-spark-thrift.sh
- Spark JARs (Downloaded in Dockerfile, e.g., spark-sql_2.12-3.5.0.jar, spark-hive_2.12-3.5.0.jar, hudi-spark3.5.x_2.13-1.0.2.jar, etc.)
- AWS credentials (for S3 access if needed)
- as mentioned in docker-compose.yml, you should mount the following volumes for accessing logs and your local "hive.metastore.warehouse.dir"

```bash
  - ./spark-data-volume:/opt/spark/work-dir/data
  - ./logs:/opt/spark/logs
```


### Run the Container

```bash
# Setup environment variables
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_SESSION_TOKEN=
AWS_DEFAULT_REGION=


# use docker-compose
docker-compose down && docker-compose up --build -d  && docker-compose logs -f

```


## Connecting to the Server

### Using beeline

```bash
docker exec -it spark-thrift-server /opt/spark/bin/beeline -u 'jdbc:hive2://localhost:10000/default;auth=noSasl' -n hive -p password --hiveconf hive.server2.thrift.port=10000


# Or you can connect in beeline cli
!connect jdbc:hive2://localhost:10000/default;auth=noSasl hive password org.apache.hive.jdbc.HiveDriver

# testing connection using test_spark_connection.py

# install using pyproject.toml
pip install .

python test_spark_connection.py

```
