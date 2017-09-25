#!/bin/bash -e

echo "Using:"
echo -e "\tConfig file   : ${CONF_FILE:=/conf/aptly.conf}"
echo -e "\tListen port   : ${PORT:=8000}"
echo -e "\tCron schedule : ${CRON_SCHEDULE}"
echo -e "\tPrivate key   : ${PRIVATE_KEY}"


if [ ! -f "${CONF_FILE}" ]; then
    echo "Config file ${CONF_FILE} does not exit"
    exit 1
fi

if [ -n "${CRON_SCHEDULE}" ]; then
    echo -e "${CRON_SCHEDULE} $(whoami) CONF_FILE=${CONF_FILE} /usr/local/bin/mirror.sh >> /proc/1/fd/1 2>&1\n" > /etc/cron.d/aptly_update_mirrors
fi

if [ -f "${PRIVATE_KEY}" ]; then
    gpg --import $PRIVATE_KEY || true
fi

# TODO: setup S3PublishEndpoints

exec aptly api serve -config=${CONF_FILE} -no-lock -listen=:${PORT}
