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
  -e SHOW_CRONS=false \
  -e DEBUG=false \
  mbentley/get-dtr-job-logs
```

The following environment variables are required: `DTR_URL`, `USERNAME`, `PASSWORD`, `JOB_TYPE`. The job type (`JOB_TYPE`) can be looked up using the [list of available types from the DTR docs](https://docs.docker.com/ee/dtr/admin/monitor-and-troubleshoot/troubleshoot-batch-jobs/#job-types).  You may also use `any` to get logs from all jobs.  `PASSWORD` can also be an [access token](https://docs.docker.com/ee/dtr/user/access-tokens/).

You can use `SHOW_CRONS=true` to also list the schedule cron jobs.  Crons run as jobs; this will only display the cron schedules for each type of cron job:

<details/>
  <summary>Example:</summary><p>
---
```
$ docker run --rm \
  -e DTR_URL=dtr.example.com \
  -e USERNAME=username \
  -e PASSWORD=password \
  -e SHOW_CRONS=true \
  mbentley/get-dtr-job-logs
====== BEGIN cron list ======
{
  "id": "6ec4f90a-15b5-470d-9a3b-40d8eaa82cc7",
  "action": "poll_mirror",
  "schedule": "0 */15 * * * *",
  "retries": 0,
  "capacityMap": null,
  "parameters": null,
  "deadline": "",
  "stopTimeout": "",
  "nextRun": "2018-04-21T11:45:00Z"
}
{
  "id": "a1d7caf1-19ef-4748-bcf7-e47dae55e30f",
  "action": "license_update",
  "schedule": "53 42 6 * * *",
  "retries": 2,
  "capacityMap": null,
  "parameters": null,
  "deadline": "",
  "stopTimeout": "",
  "nextRun": "2018-04-22T06:42:53Z"
}
{
  "id": "193c061a-c52c-448a-884a-719adc253497",
  "action": "gc",
  "schedule": "0 0 1 * * 6",
  "retries": 2,
  "capacityMap": {},
  "parameters": {},
  "deadline": "15m",
  "stopTimeout": "30s",
  "nextRun": "2018-04-28T01:00:00Z"
}
{
  "id": "252a9cfc-2b78-4d99-9b22-29ac038adfc6",
  "action": "update_vuln_db",
  "schedule": "45 35 19 * * *",
  "retries": 0,
  "capacityMap": null,
  "parameters": null,
  "deadline": "",
  "stopTimeout": "",
  "nextRun": "2018-04-21T19:35:45Z"
}
====== END cron list ======
```
---
</p></details>
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
