FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:b2bd6c739794856a67d0c915898ebcd1532572947e17df276624fd4fd43be3a3 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:b2bd6c739794856a67d0c915898ebcd1532572947e17df276624fd4fd43be3a3
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
