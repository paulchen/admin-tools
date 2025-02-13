ARG NEXTCLOUD_VERSION
FROM nextcloud:${NEXTCLOUD_VERSION}

RUN apt-get update && \
	apt-get -y install --no-install-recommends sudo && \
	rm -rf /var/cache/apt/archives /var/lib/apt/lists/*


