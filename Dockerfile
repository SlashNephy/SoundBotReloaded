FROM --platform=$TARGETPLATFORM node:22.12.0-bullseye-slim@sha256:9f385b101f66ecdf9ed9218d000cd5a35600722f0aab8112632371765109c065 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.12.0-bullseye-slim@sha256:9f385b101f66ecdf9ed9218d000cd5a35600722f0aab8112632371765109c065
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
