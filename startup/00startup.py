import subprocess
from google.cloud.bigquery import magics

# We are assuming all notebooks have a name of teamname-personname-notebook
output = subprocess.check_output("hostname", shell=True).decode('utf-8').split('-')
team_name = output[0]
person_name = output[1:-1]

# Updating the BigQuery magic default query job config, so that BQ cell magics automatically have a team_name and person_name label applied to them.
if not magics.context.default_query_job_config.labels:
    magics.context.default_query_job_config.labels = {'team_name': team_name, 'person_name': person_name}
else:
    magics.context.default_query_job_config.labels['team_name'] = team_name
    magics.context.default_query_job_config.labels['person_name'] = person_name
