FROM resin/resin-base:latest

RUN apt-get update \
	&& apt-get install --install-recommends apt-transport-https wget python-dev python \
	&& echo "deb https://packagecloud.io/librato/librato-collectd/debian/ jessie main" >> /etc/apt/sources.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-key C2E73424D59097AB \
	&& apt-get update \
	&& apt-get download collectd \
	&& apt-get install `apt-cache depends collectd | awk '/Depends:/{print$2}'` \
	&& dpkg --unpack collectd*.deb \
	&& sed -i 's/${SYSTEMCTL_BIN} daemon-reload//g' /var/lib/dpkg/info/collectd.postinst \
	&& sed -i 's/${SYSTEMCTL_BIN} start collectd//g' /var/lib/dpkg/info/collectd.postinst \
	&& dpkg --configure collectd \
	&& rm collectd*.deb \
	&& rm -rf /var/lib/apt/lists/*

# Librato default configuration
COPY librato/*.conf /opt/collectd/etc/collectd.conf.d/
COPY librato/collectd.service /lib/systemd/system/collectd.service
COPY librato/confd /usr/src/app/config/confd

RUN rm /opt/collectd/etc/collectd.conf.d/swap.conf && \
    rm /opt/collectd/etc/collectd.conf.d/librato.conf && \
    rm /opt/collectd/etc/collectd.conf.d/varnish.conf

# Override confd.service
COPY librato/confd.service /etc/systemd/system/
