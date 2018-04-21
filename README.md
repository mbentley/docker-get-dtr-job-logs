docker-get-dtr-job-logs
=======================


Example usage:
```
docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e JOB_TYPE=gc \
  -e JOB_LIMIT=10 \
  -e JOB_INFO_ONLY=false \
  -e DEBUG=false \
  mbentley/get-dtr-job-logs
```

The following environment variables are required: `DTR_URL`, `USERNAME`, `PASSWORD`, `JOB_TYPE`. The job type (`JOB_TYPE`) can be looked up using the [list of available types from the DTR docs](https://docs.docker.com/ee/dtr/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types).  You may also use `any` to get logs from all jobs.

If you wish to only have the high level job information returned, utilize `-e JOB_INFO_ONLY=true`.  For example, to return the job info from the last job ran of any type:


```
$ docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e JOB_TYPE=any \
  -e JOB_LIMIT=1 \
  -e JOB_INFO_ONLY=true \
  mbentley/get-dtr-job-logs
[
  {
    "id": "a261713a-9514-43f9-a7e5-50e7a9fa1d48",
    "retryFromID": "a261713a-9514-43f9-a7e5-50e7a9fa1d48",
    "workerID": "0000000000e2",
    "status": "done",
    "scheduledAt": "2017-10-02T16:54:34.717Z",
    "lastUpdated": "2017-10-02T16:58:34.727Z",
    "action": "nautilus_update_db",
    "retriesLeft": 0,
    "retriesTotal": 0,
    "capacityMap": null,
    "parameters": null,
    "deadline": "",
    "stopTimeout": "5s"
  }
]
```

Get a specific job id's logs:

```
docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e JOB_INFO_ONLY=false \
  -e DEBUG=false \
  -e JOB_ID=b4c199b8-3878-4955-9c0c-8d9eec15af9c \
  mbentley/get-dtr-job-logs
```
