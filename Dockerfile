FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:4c4d1930c335191ebcf049eec6a4d35571b1fb9468ab0b8a403724c1a6d23f58 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:4c4d1930c335191ebcf049eec6a4d35571b1fb9468ab0b8a403724c1a6d23f58
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
