FROM --platform=$TARGETPLATFORM node:21.0.0-bullseye-slim@sha256:0b45d811c7eb924e9e5c57e4cf609af27ab48d2a3db2b5fad7f5e1cd8963d720 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.0.0-bullseye-slim@sha256:0b45d811c7eb924e9e5c57e4cf609af27ab48d2a3db2b5fad7f5e1cd8963d720
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
