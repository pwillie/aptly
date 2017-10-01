#!/bin/bash -e

# mirror.sh is called by cron job and relies on /etc/aptly.conf being setup 
# correctly by the startup.sh script when container is originally created.

echo "Config file : ${CONF_FILE:=/conf/aptly.conf}"

if [ ! -f "${CONF_FILE}" ]; then
    echo "Config file ${CONF_FILE} does not exit"
    exit 1
fi

filter_=""
while read -r line; do
    filter_=${filter_:+$filter_|}${line}
done < $(dirname ${CONF_FILE})/filter.txt

function fn_mirror() {
    echo "mirror config file: ${1}"
    source ${1}

    # make sure gpg keys are present
    if [ -n "${keys}" ]; then
        gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys ${keys}
    fi

    # check if repo is already configured
    if ! aptly -config=${CONF_FILE} mirror show ${name}; then
        # create mirror
        aptly -config=${CONF_FILE} mirror create ${name} ${source} ${distribution} ${components}
    fi

    # edit repo
    aptly -config=${CONF_FILE} mirror edit \
        -architectures=${architectures} \
        -with-udebs=${with_udebs} \
        -dep-follow-all-variants=${dep_follow_all_variants} \
        -filter-with-deps=${filter_with_deps} \
        -filter=${filter_} \
        ${name}

    # update repo
    aptly -config=${CONF_FILE} mirror update ${name}
}

echo "Updating all mirrors..."
# list all configured mirrors
for f in $(find $(dirname ${CONF_FILE}) -type f -name "*.sh"); do
    echo "Processing mirror: ${f}"
    fn_mirror "${f}"
done

exit 0
# mirrors=$(aptly mirror list -raw)
# echo $mirrors
# TODO:
# report mirrors that do NOT have a config file
# aptly mirror list -raw | xargs -n 1 aptly mirror update
