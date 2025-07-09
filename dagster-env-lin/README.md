# Dagster Environment with Docker Compose

This repository contains a Docker Compose setup for running [Dagster](https://dagster.io/). The environment includes Dagster's webserver, daemon, and user code services, along with a PostgreSQL database. 

Just a reminder that, 
Dagster and Airflow are both workflow orchestration tools with distinct approaches: while Airflow excels as a task scheduler focused on workflow orchestration with execution order dependencies and task management, Dagster takes a data-centric approach with first-class support for data dependencies between steps and built-in data asset tracking with lineage.
Dagster's core philosophy centers around development experience and **data reliability**, treating data as a first-class citizen, **making it particularly well-suited for applications where understanding and validating data flow is as crucial as pipeline execution itself.**


## Prerequisites

- Docker and Docker Compose installed on your system
- Git (for version control)
- Python 3.10 and poetry (for Python dependency management), requirements are listed in `pyproject.toml`

## Project Structure

```
dagster-env-lin/
├── Dockerfile_dagster       # Base image for Dagster services
├── Dockerfile_user_code     # Image for user code execution
├── docker-compose.yml       # Main Docker Compose configuration
├── workspace.yaml          # Workspace configuration for Dagster (Define your user_code server here for dagster)
├── dagster.yaml            # Dagster instance configuration
├── pyproject.toml          # Python dependencies
├── poetry.lock             # Lock file for Python dependencies
└── projects/               # Directory for dagster projects for testing like hello world
```

## Services

The Docker Compose setup includes the following services:

1. **postgres**: PostgreSQL database for Dagster
2. **user_code**: Sample Service for running Dagster user code
3. **webserver**: Dagster's web interface (Dagit)
4. **daemon**: Dagster daemon for scheduling and sensors


## Getting Started

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone <repository-url>
   cd dagster-env-lin
   ```

2. **Create the Docker network** (if it doesn't exist):
   ```bash
   docker network create dagster_network
   ```

3. **Build and start the services**:
   ```bash
    docker-compose down && docker-compose up --build -d  && docker-compose logs -f

    # your servers should like below

    ~/w/dev2/dagster-env-lin main ?10 ❯ docker-compose ps                                                       Py NFX-CONDA-ENV-py3.8 23:44:13
    NAME                IMAGE                       COMMAND                  SERVICE     CREATED          STATUS                    PORTS
    dagster_daemon      dagster-env-lin-daemon      "dagster-daemon run"     daemon      52 minutes ago   Up 52 minutes
    dagster_postgres    postgres:11                 "docker-entrypoint.s…"   postgres    52 minutes ago   Up 52 minutes (healthy)   0.0.0.0:5432->5432/tcp
    dagster_user_code   dagster_user_code_image     "dagster code-server…"   user_code   52 minutes ago   Up 52 minutes             4000/tcp, 0.0.0.0:4001->4001/tcp
    dagster_webserver   dagster-env-lin-webserver   "dagster-webserver -…"   webserver   52 minutes ago   Up 52 minutes             0.0.0.0:3000->3000/tcp
    ~/workspace/dev2/dagster-env-lin main ?10 ❯                                                                                                 Py NFX-CONDA-ENV-py3.8 23:44:24
    ```

4. **Access the Dagster UI**:
   Open your browser and go to `http://localhost:3000` to access the Dagster web interface.


5. **Checkout the hello world project in the `projects/` directory to see how it works


6.  **Stop all services**:
  ```bash
  docker-compose down
  ```


## Sample Configuration

- **PostgreSQL**:
  - User: `postgres_user`
  - Database: `postgres_db`
  - Port: `5432`

- **Dagster Webserver**:
  - URL: `http://localhost:3000`
  - Port: `3000`

- **User Code Server**:
  - Port: `4001`


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
