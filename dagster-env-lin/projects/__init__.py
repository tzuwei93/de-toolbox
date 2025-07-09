
from .hello_world import hello_world_assets, hello_world_jobs, hello_world_schedules, hello_world_resources
from dagster import Definitions


defs = Definitions(
    assets=hello_world_assets,
    jobs=hello_world_jobs,
    schedules=hello_world_schedules,
    resources=hello_world_resources,
)

__all__ = ['defs']