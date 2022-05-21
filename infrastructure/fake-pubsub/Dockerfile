FROM google/cloud-sdk:386.0.0

EXPOSE 3334

WORKDIR /pubsub

COPY . /pubsub

RUN chmod +x /pubsub/docker-entrypoint.sh

ENTRYPOINT ["/pubsub/docker-entrypoint.sh"]