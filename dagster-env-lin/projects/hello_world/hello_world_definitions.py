from dagster import asset, resource, define_asset_job, AssetSelection, ScheduleDefinition

@asset(
    name="hello_world",
    description="A simple hello world asset.",
    group_name="hello_world",
    required_resource_keys={"hello_world"}
)
def hello_world():
    """A simple hello world asset."""
    return "Hello, World!"

# Create a job for the hello world asset
hello_world_job = define_asset_job(
    name="hello_world_job",
    selection=AssetSelection.assets(hello_world),
    description="A simple hello world job.",
)

# every day 5 am
hello_world_schedule = ScheduleDefinition(
    name="hello_world_schedule",
    job=hello_world_job,
    cron_schedule="0 5 * * *",
    description="A simple hello world schedule.",
)

@resource
def hello_world_resource(_):
    """A simple resource that returns a greeting."""
    return "Hello, World!"

# Export resources
hello_world_resources = {
    "hello_world": hello_world_resource,
}


# Export assets and jobs
hello_world_assets = [hello_world]
hello_world_jobs = [hello_world_job]
hello_world_schedules = [hello_world_schedule]

__all__ = [
    'hello_world_assets',
    'hello_world_jobs',
    'hello_world_schedules',
    'hello_world_resources',
]
