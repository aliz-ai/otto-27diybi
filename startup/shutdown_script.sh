#!/bin/bash

# Download the script that sets the labels for the BigQuery magics
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
gsutil cp gs://${PROJECT_ID}-commons/00startup.py ~/.ipython/profile_default/startup/00startup.py
# Number of sequential checks when the instance had utilization below the threshold.
COUNTER=0
# If actual CPU utilization is below this threshold script will increase the counter.
THRESHOLD_PERCENT=2
# Interval between checks of the CPU utilizations.
SLEEP_INTERVAL_SECONDS=5
# How big COUNTER need to be for the script to shutdown the instance. For example,
# if we want an instance to be stopped after 20min of idle. Each utilization probe
# happens every 5sec (SLEEP_INTERVAL_SECONDS), therefore since there are 1200 seconds
# in 20 min (20 * 60 = 1200) we need counter threshold to be 240 (1200 / 5).
HALT_THRESHOLD=240

while true; do
    currenttime=$(date +%H:%M)
    if [[ "$currenttime" > "23:00" ]] || [[ "$currenttime" < "06:30" ]]; then
        CPU_PERCENT=$(mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /[0–9]/ {print $3}')
        if (( $(echo "${CPU_PERCENT} < ${THRESHOLD_PERCENT}" | bc -l) )); then
            COUNTER=$((COUNTER + 1))
            if (( $(echo "${COUNTER} > ${HALT_THRESHOLD}" | bc -l) )); then
                gcloud compute instances stop $(hostname)
            fi
        else
            COUNTER=0
        fi
    fi
    sleep "${SLEEP_INTERVAL_SECONDS}"
done