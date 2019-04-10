# dokku couchbase

# DO NOT USE (EXPERIMENT)

## requirements

- dokku 0.12.x+
- docker 1.8.x

## installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-couchbase.git couchbase
```

## commands

```
couchbase:app-links <app>          List all couchbase service links for a given app
couchbase:backup <name> <bucket> (--use-iam) Create a backup of the couchbase service to an existing s3 bucket
couchbase:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> (<aws_default_region>) (<aws_signature_version>) (<endpoint_url>) Sets up authentication for backups on the couchbase service
couchbase:backup-deauth <name>     Removes backup authentication for the couchbase service
couchbase:backup-schedule <name> <schedule> <bucket> Schedules a backup of the couchbase service
couchbase:backup-schedule-cat <name> Cat the contents of the configured backup cronfile for the service
couchbase:backup-set-encryption <name> <passphrase> Set a GPG passphrase for backups
couchbase:backup-unschedule <name> Unschedules the backup of the couchbase service
couchbase:backup-unset-encryption <name> Removes backup encryption for future backups of the couchbase service
couchbase:clone <name> <new-name>  Create container <new-name> then copy data from <name> into <new-name>
couchbase:connect <name>           NOT IMPLEMENTED
couchbase:create <name>            Create a couchbase service with environment variables
couchbase:destroy <name>           Delete the service, delete the data and stop its container if there are no links left
couchbase:enter <name> [command]   Enter or run a command in a running couchbase service container
couchbase:exists <service>         Check if the couchbase service exists
couchbase:export <name> > <file>   Export a dump of the couchbase service database
couchbase:expose <name> [port]     Expose a couchbase service on custom port if provided (random port otherwise)
couchbase:import <name> < <file>   Import a dump into the couchbase service database
couchbase:info <name>              Print the connection information
couchbase:link <name> <app>        Link the couchbase service to the app
couchbase:linked <name> <app>      Check if the couchbase service is linked to an app
couchbase:list                     List all couchbase services
couchbase:logs <name> [-t]         Print the most recent log(s) for this service
couchbase:promote <name> <app>     Promote service <name> as COUCHBASE_URL in <app>
couchbase:restart <name>           Graceful shutdown and restart of the couchbase service container
couchbase:start <name>             Start a previously stopped couchbase service
couchbase:stop <name>              Stop a running couchbase service
couchbase:unexpose <name>          Unexpose a previously exposed couchbase service
couchbase:unlink <name> <app>      Unlink the couchbase service from the app
couchbase:upgrade <name>           Upgrade service <service> to the specified version
```

## usage

```shell
# create a couchbase service named lolipop
dokku couchbase:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# couchbase image
export COUCHBASE_IMAGE="couchbase"
export COUCHBASE_IMAGE_VERSION="1.7"
dokku couchbase:create lolipop

# you can also specify custom environment
# variables to start the couchbase service
# in semi-colon separated form
export COUCHBASE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku couchbase:create lolipop

# get connection information as follows
dokku couchbase:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku couchbase:info lolipop --config-dir
dokku couchbase:info lolipop --data-dir
dokku couchbase:info lolipop --dsn
dokku couchbase:info lolipop --exposed-ports
dokku couchbase:info lolipop --id
dokku couchbase:info lolipop --internal-ip
dokku couchbase:info lolipop --links
dokku couchbase:info lolipop --service-root
dokku couchbase:info lolipop --status
dokku couchbase:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku couchbase:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku couchbase:enter lolipop ls -lah /

# a couchbase service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku couchbase:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_COUCHBASE_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_COUCHBASE_LOLIPOP_PORT=tcp://172.17.0.1:5984
#   DOKKU_COUCHBASE_LOLIPOP_PORT_5984_TCP=tcp://172.17.0.1:5984
#   DOKKU_COUCHBASE_LOLIPOP_PORT_5984_TCP_PROTO=tcp
#   DOKKU_COUCHBASE_LOLIPOP_PORT_5984_TCP_PORT=5984
#   DOKKU_COUCHBASE_LOLIPOP_PORT_5984_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   COUCHBASE_URL=couchbase://lolipop:SOME_PASSWORD@dokku-couchbase-lolipop:5984/lolipop
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku couchbase:link other_service playground

# since COUCHBASE_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_COUCHBASE_BLUE_URL=couchbase://other_service:ANOTHER_PASSWORD@dokku-couchbase-other-service:5984/other_service

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku couchbase:promote other_service playground

# this will replace COUCHBASE_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   COUCHBASE_URL=couchbase://other_service:ANOTHER_PASSWORD@dokku-couchbase-other-service:5984/other_service
#   DOKKU_COUCHBASE_BLUE_URL=couchbase://other_service:ANOTHER_PASSWORD@dokku-couchbase-other-service:5984/other_service
#   DOKKU_COUCHBASE_SILVER_URL=couchbase://lolipop:SOME_PASSWORD@dokku-couchbase-lolipop:5984/lolipop

# you can also unlink a couchbase service
# NOTE: this will restart your app and unset related environment variables
dokku couchbase:unlink lolipop playground

# you can tail logs for a particular service
dokku couchbase:logs lolipop
dokku couchbase:logs lolipop -t # to tail

# you can dump the database
dokku couchbase:export lolipop > lolipop.dump

# you can import a dump
dokku couchbase:import lolipop < database.dump

# you can clone an existing database to a new one
dokku couchbase:clone lolipop new_database

# finally, you can destroy the container
dokku couchbase:destroy lolipop
```

## Changing database adapter

It's possible to change the protocol for DATABASE_URL by setting
the environment variable COUCHBASE_DATABASE_SCHEME on the app:

```
dokku config:set playground COUCHBASE_DATABASE_SCHEME=couchbase2
dokku couchbase:link lolipop playground
```

Will cause COUCHBASE_URL to be set as
couchbase2://lolipop:SOME_PASSWORD@dokku-couchbase-lolipop:5984/lolipop

CAUTION: Changing COUCHBASE_DATABASE_SCHEME after linking will cause dokku to
believe the service is not linked when attempting to use `dokku couchbase:unlink`
or `dokku couchbase:promote`.
You should be able to fix this by

- Changing COUCHBASE_URL manually to the new value.

OR

- Set COUCHBASE_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change COUCHBASE_DATABASE_SCHEME to the desired setting
- Relink the service

## Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2
and has access to the bucket via an IAM profile. In that case, use the `--use-iam`
option with the `backup` command.

Backups can be performed using the backup commands:

```
# setup s3 backup authentication
dokku couchbase:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# remove s3 authentication
dokku couchbase:backup-deauth lolipop

# backup the `lolipop` service to the `BUCKET_NAME` bucket on AWS
dokku couchbase:backup lolipop BUCKET_NAME

# schedule a backup
# CRON_SCHEDULE is a crontab expression, eg. "0 3 * * *" for each day at 3am
dokku couchbase:backup-schedule lolipop CRON_SCHEDULE BUCKET_NAME

# cat the contents of the configured backup cronfile for the service
dokku couchbase:backup-schedule-cat lolipop

# remove the scheduled backup from cron
dokku couchbase:backup-unschedule lolipop
```

Backup auth can also be set up for different regions, signature versions and endpoints (e.g. for minio):

```
# setup s3 backup authentication with different region
dokku couchbase:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

# setup s3 backup authentication with different signature version and endpoint
dokku couchbase:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL

# more specific example for minio auth
dokku couchbase:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

## Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `COUCHBASE_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
