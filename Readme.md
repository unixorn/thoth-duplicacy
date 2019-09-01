# thoth-duplicacy

## About

This container installs both [duplicacy](https://github.com/gilbertchen/duplicacy) and [duplicacy-util](https://github.com/jeffaco/duplicacy-util) on top of debian buster-slim.

## Motivation

I wanted to backup up my NAS and ARM cluster to B2 because:

* CrashPlan for home is dead
* I don't want to pay per-machine for backups, I'd rather just pay for the storage
* B2 is super cheap compared to the other options I looked at

## Usage

I've tried to make this image as easy to use as possible. It expects to find the directory you want to back up mounted to the container as `/data`, and that there is a `.duplicacy` directory with proper settings at the root level of the directory.

### Building the image

Change `CONTAINER_NAME` in the included `Rakefile` and run `rake build_container` to build an architecture-specific container yourself. If you want to use the experimental buildx support in Docker to generate a multi-architecture build, run `rake buildx` instead.

I've had issues with getting my multi-architecture builds to work on ARM though, so I publish separate images for Intel and ARM7 on docker hub as `unixorn/thoth-duplicacy:armv7l` and `unixorn/thoth-duplicacy:x86_64`.

### Using with docker-compose

If you just want to run it with `docker`, you can run it with `docker-compose`. There are a few environment variables that the included `backup-cronjob` script looks for so it knows how many threads to run and where to write the backups.

`BACKUP_LOCATION=/path/to/somewhere docker-compose run thoth-duplicacy backup-cronjob`

### Using inside Kubernetes

I have an ARM cluster running k3s on some ODROID HC2s and Raspberry Pis. I run moosefs on the cluster as a distributed file system, and wanted to back it up in as simple a way as possible.

By running the backup as a kubernetes cron job, I don't have to maintain a crontab on any of the cluster nodes, I created a `cronjob-backup-stuff.yml` in my cluster's configuration git repo, and kubernetes will ensure that the backups run on the least-loaded node.

#### Backing up directories

Here's a sample job that backs up one of my samba volumes. Note that I've created a `backups` namespace in my cluster to keep things tidy - if you want to pollute your default namespace instead, delete the namespace entry in the metadata section.

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: backup-exampledir
  namespace: backups
spec:
  schedule: "35 */2 * * *"
  jobTemplate:
    spec:
      # Ensure only one copy of the backup is running, even if it runs
      # so long that it is still running when the next cron slot comes up
      concurrencyPolicy: Forbid
      template:
        spec:
          containers:
          - name: backup-exampledir
            # I'm running this on the odroids in my cluster, so I'm specifying
            # the ARM7 build
            image: unixorn/thoth-duplicacy:arm7l
            # Use the x86_64 tag if you're on Intel
            # image: unixorn/thoth-duplicacy:x86_64
            args:
            - /bin/sh
            - -c
            - /usr/local/bin/backup-cronjob

            volumeMounts:
              - name: data-volume
                mountPath: /data/

            env:
                # I want to restrict the number of threads used for uploads
                # so that duplicacy doesn't consume all my upload bandwidth.
                # I don't care if backups are slow.
              - name: DUPLICACY_BACKUP_THEAD_COUNT
                value: "3"
                # backup-cronjob needs to know what defined storage to back up
                # files to.
              - name: B2_STORAGE_NAME
                value: "b2"

          restartPolicy: OnFailure

          # Keep it running on a chunkserver so that at least part of the
          # I/O is to local disk instead of across the network. Remove if
          # you don't care what node backups happen on.
          nodeSelector:
            odroid: "true"

          volumes:
            - name: data-volume
              hostPath:
                # This will be remapped to /data which is where duplicacy
                # expects to find the data it is backing up, and the .duplicacy
                # directory with its settings.
                path: /dfs/volumes/exampledir
                # this field is optional
                type: Directory

```

#### Pruning snapshots

We don't want to keep snapshots forever. Here's a Kubernetes cronjob to clean them up.

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: purge-stale-duplicacy-snapshots
  namespace: backups
spec:
  schedule: "48 */3 * * *"
  jobTemplate:
    spec:
      concurrencyPolicy: Forbid
      template:
        spec:
          containers:
          - name: purge-stale-duplicacy-snapshots
            # I'm running this on the odroids in my cluster, so I'm specifying
            # the ARM7 build
            image: unixorn/thoth-duplicacy:arm7l
            # Use the x86_64 tag if you're on Intel
            # image: unixorn/thoth-duplicacy:x86_64

            # Make sure we run inside /data so that duplicacy can find
            # the configuration directory.
            workingDir: /data

            # Remember that the -keep arguments must be listed from longest
            # time frame to shortest, otherwise the disordered ones will be
            # ignored, which could mean deleting snapshots you want to keep.
            #
            # I'm specifying to keep no snapshots more than 365 days old, keep
            # a single snapshot every 30 days for snapshots older than 90 days,
            # a single snapshot a week for snapshots older than 30 days, and 
            # finally keep only a single snapshot per day for snapshots
            # older than 2 days.
            #
            # Also note that the duplicacy verb has to come before any of the
            # settings command line options.
            args:
            - duplicacy
            - prune
            - -storage
            - b2
            - -all
            - -keep 0:365
            - -keep 30:90
            - -keep 7:30
            - -keep 1:2
            - -exhaustive

            volumeMounts:
              - name: data-volume
                mountPath: /data/

            env:
              - name: DUPLICACY_BACKUP_THEAD_COUNT
                value: "3"
              - name: B2_STORAGE_NAME
                value: "b2"

          restartPolicy: OnFailure

          # Keep it running on one of the cluster chunkservers so that at
          # least part of the I/O is to local disk instead of across the
          # network. Remove if you don't care what node backups happen on.
          nodeSelector:
            odroid: "true"

          volumes:
            - name: data-volume
              hostPath:
                # This will be remapped to /data which is where duplicacy
                # expects to find the data it is backing up, and the .duplicacy
                # directory with its settings.
                path: /dfs/volumes/exampledir
                # this field is optional
                type: Directory
```

## License

This repository is copyright 2019, Joe Block <jpb@unixorn.net> and is Apache 2.0 licensed.

duplicacy and duplicacy-util have their own licenses, see the links above for details
