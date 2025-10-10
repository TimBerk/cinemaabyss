FROM kong:3.9.0

USER root

RUN apt-get update && apt-get install -y gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY kong.yml /etc/kong/kong.yml.template

RUN chmod +x /entrypoint.sh

USER kong

ENTRYPOINT ["/entrypoint.sh"]
CMD ["kong", "docker-start"]