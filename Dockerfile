FROM --platform=$TARGETPLATFORM node:21.1.0-bullseye-slim@sha256:2c247f69ae354d692fcb76cab79cdbaa14485c0e0375a70efca9a98201b4ed29 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.1.0-bullseye-slim@sha256:2c247f69ae354d692fcb76cab79cdbaa14485c0e0375a70efca9a98201b4ed29
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
