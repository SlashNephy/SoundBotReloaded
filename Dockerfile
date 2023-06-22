FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:c92280d8fb6e7ca07f258c45e9f18cb643ea798a5441855a05e982cfd2b90789 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:c92280d8fb6e7ca07f258c45e9f18cb643ea798a5441855a05e982cfd2b90789
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
