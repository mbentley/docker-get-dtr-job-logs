#!/bin/sh

set -e

if [ -z "${DTR_URL}" ]
then
  echo "Missing DTR_URL environment variable"
  exit 1
fi

if [ -z "${USERNAME}" ]
then
  echo "Missing USERNAME environment variable"
  exit 1
fi

if [ -z "${PASSWORD}" ]
then
  echo "Missing PASSWORD environment variable"
  exit 1
fi

if [ -z "${JOB_TYPE}" ]
then
  echo "Missing JOB_TYPE environment variable"
  echo "For a list of job types, see https://docs.docker.com/datacenter/dtr/2.3/guides/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types"
  exit 1
fi

if [ "${ALL_JOBS}" = true ] || [ "${ALL_JOBS}" = "1" ]
then
  NUM_JOBS=""
else
  NUM_JOBS="0"
fi

# get last job id
LAST_JOB_ID="$(curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs?action=${JOB_TYPE}&worker=any&running=any&start=0" | jq -r .jobs[${NUM_JOBS}].id)"

# check to see if job id returned
if [ "${LAST_JOB_ID}" = "null" ]
then
  echo "No jobs found of type '${JOB_TYPE}'"
  exit 1
fi

for JOB in ${LAST_JOB_ID}
do
  echo "BEGIN job logs from ${JOB}"
  echo "=================================================="
  # get job job id from the last ${JOB_TYPE} job and send that to get the job logs
  curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB}/logs" | jq -r .[].Data
  echo "END job logs from ${JOB}"
  echo "==================================================";echo
done
