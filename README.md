docker-get-dtr-job-logs
=======================


Example usage:
```
docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e JOB_TYPE=gc \
  -e ALL_JOBS=false \
  mbentley/get-dtr-job-logs
```

All of the above environment variables are required, except for `ALL_JOBS` which defaults to false which will only get the last job's jobs.  The job type (`JOB_TYPE`) can be looked up using the list of available types from the DTR docs: https://docs.docker.com/datacenter/dtr/2.3/guides/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types
