FROM --platform=$TARGETPLATFORM node:22.19.0-bullseye-slim@sha256:535c6223132f2c4b874d604aab6233c41e968ec9a0e9b11bf021b920abc972b2 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.19.0-bullseye-slim@sha256:535c6223132f2c4b874d604aab6233c41e968ec9a0e9b11bf021b920abc972b2
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
