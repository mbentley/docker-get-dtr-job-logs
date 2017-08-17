docker-get-dtr-job-logs
=======================


Example usage:
```
docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e JOB_TYPE=gc \
  mbentley/get-dtr-job-logs
```

All of the above environment variables are required.  The job type can be looked up using the list of available types from the DTR docs: https://docs.docker.com/datacenter/dtr/2.3/guides/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types
