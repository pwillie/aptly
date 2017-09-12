FROM phusion/baseimage:0.9.22

RUN apt-get update && apt-get install -y -q \
    aptly \
    realpath \
 && rm -rf /var/lib/apt/lists/*

ADD startup.sh /usr/local/bin/
ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/bin/startup.sh"]
