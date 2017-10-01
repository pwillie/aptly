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

## Publishing

curl -X POST -H 'Content-Type: application/json' --data '{"SourceKind": "local", "Sources": [{"Name": "scanner"}], "Distribution": "masters"}' http://localhost:8000/api/publish/s3:test:debian

curl -X POST -H 'Content-Type: application/json' --data '{"SourceKind": "snapshot", "Sources":[{"Name": "test1"}], "Distribution": "stretch"}' http://localhost:8000/api/publish/s3:test:debian

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DDCB0F755806C4B6