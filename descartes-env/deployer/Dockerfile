FROM node:12-alpine

# install dockerize, as we need to wait on ganache to be responding
RUN apk add --no-cache \
    build-base \
    git \
    openssl \
    python \
    python-dev \
    py-pip \
    rsync

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV BASE /opt/cartesi

RUN yarn global add truffle@5.1.31

WORKDIR $BASE/deployer
COPY deployer/* ./

# download smart contract dependencies
RUN yarn

ENV ETHEREUM_HOST "ganache"
ENV ETHEREUM_PORT "8545"
ENV ETHEREUM_TIMEOUT "10s"
ENV ETHEREUM_NETWORK "development"

CMD dockerize \
    -wait tcp://${ETHEREUM_HOST}:${ETHEREUM_PORT} \
    -timeout ${ETHEREUM_TIMEOUT} \
    $BASE/deployer/migrate.sh
