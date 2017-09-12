#!/bin/bash -e

cron_cmd='cron -f'

echo "Using:"
echo -e "\tConfig dir    : ${CONF_DIR:=/conf}"
echo -e "\tData dir      : ${DATA_DIR:=/data}"
echo -e "\tListen port   : ${PORT:=8000}"
echo -e "\tCron schedule : ${CRON_SCHEDULE}"

if [ ! -d "$CONF_DIR" ]; then
    echo "CONF_DIR ${CONF_DIR} does not exit"
    exit 1
fi

if [ ! -d "$DATA_DIR" ]; then
    echo "DATA_DIR ${DATA_DIR} does not exit"
    exit 1
fi

if [ -n "${CRON_SCHEDULE}" ]; then
    echo -e "${CRON_SCHEDULE} $(whoami) $(realpath $0) update_mirrors >> /proc/1/fd/1 2>&1\n" > /etc/cron.d/aptly_update_mirrors
fi
echo "{ \"rootDir\": \"${DATA_DIR}\" }" > /etc/aptly.conf

function fn_usage() {
    echo "usage:"
    echo -e "\t$0"
    echo -e "\t$0 update_mirrors"
    exit 1
}

function fn_api() {
    exec aptly api serve -listen=:${PORT}
    exit $?
}

function fn_mirror() {
    echo "mirror config file: ${1}"
    source ${1}

    filter_=""
    while read -r line; do
        filter_=${filter_:+$filter_|}${line}
    done <<< "${filter}"

    # make sure gpg keys are present
    if [ -n "${keys}" ]; then
        gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys ${keys}
    fi

    # check if repo is already configured
    if ! aptly mirror show ${name}; then
        # create mirror
        aptly mirror create ${name} ${source} ${distribution} ${components}
    fi

    # edit repo
    aptly mirror edit \
        -architectures=${architectures} \
        -with-udebs=${with_udebs} \
        -dep-follow-all-variants=${dep_follow_all_variants} \
        -filter-with-deps=${filter_with_deps} \
        -filter=${filter_} \
        ${name}
    
    # update repo
    aptly mirror update ${name}    
}

function fn_update_mirrors() {
    echo "Updating all mirrors..."
    # list all configured mirrors
    for f in $(find ${CONF_DIR} -type f -name "*.sh"); do
        echo "Processing mirror: ${f}"
        fn_mirror "${f}"
    done

    exit 0
    mirrors=$(aptly mirror list -raw)
    echo $mirrors
    # TODO:
    # report mirrors that do NOT have a config file
    # aptly mirror list -raw | xargs -n 1 aptly mirror update
}

case "${1}" in
    'update_mirrors')
        fn_update_mirrors
        ;;
    *)
        fn_api $1
        ;;
esac
