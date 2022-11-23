FROM node:16-alpine3.14

RUN apk add --no-cache git python3 make musl-dev gcc g++

ENV BASE /opt/cartesi

WORKDIR $BASE/share/blockchain
COPY yarn.lock .
COPY package.json .
COPY hardhat.config.ts .

RUN yarn 

EXPOSE 8545  

CMD ["npx", "hardhat",  "node" ]
