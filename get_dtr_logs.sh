#!/bin/sh

set -e
set -o pipefail

curl_failure() {
  echo "Error: curl to '${1}' failed. Run with '-e DEBUG=true' for additional detail"
  exit 1
}

# set defaults
SHOW_CRONS="${SHOW_CRONS:-false}"
JOB_LIMIT="${JOB_LIMIT:-10}"
JOB_INFO_ONLY="${JOB_INFO_ONLY:-false}"
JOB_ID="${JOB_ID:-}"
JOB_TYPE="${JOB_TYPE:-any}"

# check to see if show debug info
if [ "${DEBUG}" = true ] || [ "${DEBUG}" = "1" ]
then
  set -x
fi

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

if [ -z "${JOB_TYPE}" ] && [ -z "${JOB_ID}" ]
then
  echo "Missing JOB_TYPE environment variable"
  echo "For a list of job types, see https://docs.docker.com/ee/dtr/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types"
  exit 1
fi

# get cron info
if [ "${SHOW_CRONS}" = "true" ]
then
  echo "====== BEGIN scheduled cron list ======"
  (curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/crons" | jq '.crons|.[]') || curl_failure "https://${DTR_URL}/api/v0/crons"
  echo "====== END scheduled cron list ======"; echo
  exit 0
fi

# find the DTR version from the API docs
DTR_VERSION=$(curl -sk "https://${DTR_URL}/api/v0/docs.json" | jq -r .info.version) || curl_failure "https://${DTR_URL}/api/v0/docs.json"

# get job info
if [ -z "${JOB_ID}" ]
then
  # get job info based off of JOB_LIMIT, JOB_TYPE
  JOBS=$(curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs?action=${JOB_TYPE}&worker=any&running=any&start=0&limit=${JOB_LIMIT}" | jq '.jobs|.[]') || curl_failure "https://${DTR_URL}/api/v0/jobs?action=${JOB_TYPE}&worker=any&running=any&start=0&limit=${JOB_LIMIT}"
else
  # get job info based off of JOB_ID
  JOBS=$(curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB_ID}") || curl_failure "https://${DTR_URL}/api/v0/jobs/${JOB_ID}"

  # check for an error
  if [ "$(echo "${JOBS}" | jq -r '.errors|.[].code' 2>/dev/null)" = "NO_SUCH_JOB" ]
  then
    echo "Error: $(echo "${JOBS}" | jq -r '.errors|.[].message') (${JOB_ID})"
    exit 1
  fi
fi

# check to see if no jobs were returned
if [ -z "${JOBS}" ]
then
  echo "Warning: No jobs returned of type ${JOB_TYPE}"
  exit 0
fi

# check to see if we should return a list of the jobs or get the logs for the jobs
if [ "${JOB_INFO_ONLY}" = true ] || [ "${JOB_INFO_ONLY}" = "1" ]
then
  # display info about matching jobs
  echo "${JOBS}"
  exit 0
fi

# get job id(s)
JOB_IDS="$(echo "${JOBS}" | jq -r .id)"

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
  (curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB}" | jq .) || curl_failure "https://${DTR_URL}/api/v0/jobs/${JOB}"
  echo

  # get job job id from the last ${JOB_TYPE} job and send that to get the job logs
  if [ "$(echo "${DTR_VERSION}" | awk -F '.' '{print $1}')" -ge "2" ] && [ "$(echo "${DTR_VERSION}" | awk -F '.' '{print $2}')" -ge "5" ]
  then
    # DTR 2.5 and above uses lower case
    DATA="data"
  else
    # DTR 2.4 and below use upper case
    DATA="Data"
  fi
  JOB_LOGS=$(curl -ks -X GET --header "Accept: application/json" -u "${USERNAME}:${PASSWORD}" "https://${DTR_URL}/api/v0/jobs/${JOB}/logs" | jq -r .[].${DATA}) || curl_failure "https://${DTR_URL}/api/v0/jobs/${JOB}/logs"

  # check to see if no job logs were returned
  if [ -z "${JOB_LOGS}" ]
  then
    echo "Warning: No job logs returned from ${JOB}"
  else
    echo "${JOB_LOGS}"
  fi
  echo "====== END job logs from ${JOB} ======"; echo
done
