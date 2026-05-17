FROM debian:bookworm-slim@sha256:2749ca60ffb3c42de053229d7967d292d7dad1067936b38995da0bbfb96c4c23 AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

ARG BW_VERSION=2025.4.0

RUN curl -fsSL "https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${BW_VERSION}.zip" \
    -o /tmp/bw.zip \
    && unzip -q /tmp/bw.zip -d /usr/local/bin \
    && rm /tmp/bw.zip \
    && chmod +x /usr/local/bin/bw

FROM debian:bookworm-slim@sha256:2749ca60ffb3c42de053229d7967d292d7dad1067936b38995da0bbfb96c4c23

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates jq fzf cron openssh-server \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/bw /usr/local/bin/bw-real



# Add non-root user
RUN groupadd -g 1000 vault && \
    useradd -r -u 1000 -g vault -d /home/vault -s /bin/sh vault

# Install su-exec for running specific commands as root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates jq fzf cron openssh-server dumb-init \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create required directories with proper ownership
RUN mkdir -p /home/vault/.ssh /dev/shm /run/sshd /var/spool/cron /var/run && \
    chown -R vault:vault /home/vault /dev/shm && \
    chmod 700 /home/vault/.ssh && \
    chmod 755 /run/sshd /var/spool/cron /var/run

COPY --chown=vault:vault entrypoint.sh /entrypoint.sh
COPY --chown=vault:vault bw-wrapper.sh /usr/local/bin/bw
RUN chmod +x /entrypoint.sh /usr/local/bin/bw

COPY --chown=vault:vault bw-unlock.sh /usr/local/bin/bw-unlock
RUN chmod +x /usr/local/bin/bw-unlock

COPY --chown=vault:vault bw-list.sh /usr/local/bin/bw-list
RUN chmod +x /usr/local/bin/bw-list

COPY --chown=vault:vault bw-fzf.sh /usr/local/bin/bw-fzf
RUN chmod +x /usr/local/bin/bw-fzf

COPY --chown=vault:vault bw-getpw.sh /usr/local/bin/bw-getpw
RUN chmod +x /usr/local/bin/bw-getpw

COPY --chown=vault:vault bw-add.sh /usr/local/bin/bw-add
RUN chmod +x /usr/local/bin/bw-add

COPY --chown=vault:vault bw-remove.sh /usr/local/bin/bw-remove
RUN chmod +x /usr/local/bin/bw-remove

COPY --chown=vault:vault bw-state.sh /usr/local/bin/bw-state
RUN chmod +x /usr/local/bin/bw-state

# Add health check script (run as root)
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
