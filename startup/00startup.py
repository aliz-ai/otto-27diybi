import subprocess
from google.cloud.bigquery import magics
output = subprocess.check_output("hostname", shell=True).decode('utf-8').split('-')
teamname = output[0]
personname = output[1]
if not magics.context.default_query_job_config.labels:
    magics.context.default_query_job_config.labels = {'team_name': teamname, 'person_name': personname}
else:
    magics.context.default_query_job_config.labels['team_name'] = teamname
    magics.context.default_query_job_config.labels['person_name'] = personname