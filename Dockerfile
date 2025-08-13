FROM --platform=$TARGETPLATFORM node:22.18.0-bullseye-slim@sha256:8b1d14e4e6d2c100437554eb44e06d90f8315a6d717a853ec8e840223c93077e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.18.0-bullseye-slim@sha256:8b1d14e4e6d2c100437554eb44e06d90f8315a6d717a853ec8e840223c93077e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
