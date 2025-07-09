# DE Toolbox

A collection of data engineering tools and utilities to streamline your data workflows.


## Current Tools

### Dagster local environment
A local Dagster development environment with Docker Compose, featuring the webserver, daemon, and a sample user code services(defined in the same docker-compose.yml), along with PostgreSQL. This setup is for developing and testing data pipelines with Dagster's modern data orchestration capabilities.

- [dagster-env-lin](./dagster-env-lin/): Containerized Dagster environment with all necessary components

### Spark Thrift Server
A local Spark Thrift server implementation for development and testing purposes. This tool provides a JDBC/ODBC interface for running SQL queries on Spark SQL. And also it can be used to query hudi table located in S3 without predefined meta store.

- [spark-thrift-local-server](./spark-thrift-local-server/): Local Spark Thrift server setup with Docker

## Future Additions

Still working on expanding our toolbox with more modern data stack tools. Stay tuned for updates on new additions that will help you build robust data pipelines and workflows.

## License

MIT License

