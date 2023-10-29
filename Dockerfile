FROM --platform=$TARGETPLATFORM node:21.1.0-bullseye-slim@sha256:caa20b1d12bfda5fe3fb4078eb4b0a95665daadae335066490c058cf7ff3e341 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.1.0-bullseye-slim@sha256:caa20b1d12bfda5fe3fb4078eb4b0a95665daadae335066490c058cf7ff3e341
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
