# aptly
Docker container containing aptly

## Run

Arguments:

api {listen port}
cron {cron schedule pattern}
update_mirrors

## Config

Mount the aptly mirror config files at /conf

Mount the aptly storage volume at /data

### Mirror config file format: