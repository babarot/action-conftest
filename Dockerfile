FROM golang:1.13.7-stretch

ENV CONFTEST_VERSION=0.15.0

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        vim \
    && rm -rf /var/lib/apt/lists/*

# Install instrumenta/conftest
RUN mkdir -p /tmp/conftest \
    && cd /tmp/conftest \
    && wget https://github.com/instrumenta/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz \
    && tar xzf conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz \
    && mv -v conftest /usr/local/bin/conftest \
    && cd / \
    && rm -rf /tmp/conftest

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
