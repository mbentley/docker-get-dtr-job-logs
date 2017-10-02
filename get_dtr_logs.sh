#!/bin/sh

set -e

# make sure all variable have been provided
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

# get job info
JOBS="$(curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs?action=${JOB_TYPE}&worker=any&running=any&start=0")"

# check to see if we should query for all jobs or just the last
if [ "${ALL_JOBS}" = true ] || [ "${ALL_JOBS}" = "1" ]
then
  NUM_JOBS=""
else
  NUM_JOBS="0"
fi

# check to see if we should return a list of the jobs or get the logs for the jobs
if [ "${JOB_INFO}" = true ] || [ "${JOB_INFO}" = "1" ]
then
  # display info about matching jobs
  echo "${JOBS}" | jq -r '[ .jobs['${NUM_JOBS}'] ]'
  exit 0
fi

# get job id(s)
JOB_IDS="$(echo "${JOBS}" | jq -r .jobs[${NUM_JOBS}].id)"

# check to see if job id returned null
if [ "${JOB_IDS}" = "null" ]
then
  echo "No jobs found of type '${JOB_TYPE}'"
  exit 1
fi

# get the job logs for each job
for JOB in ${JOB_IDS}
do
  echo "====== BEGIN job logs from ${JOB} ======"
  # output info about the job
  curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB}" | jq .
  echo

  # get job job id from the last ${JOB_TYPE} job and send that to get the job logs
  curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB}/logs" | jq -r .[].Data
  echo "====== END job logs from ${JOB} ======"; echo
done
