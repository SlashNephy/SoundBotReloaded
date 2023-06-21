FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:b25b07f3ca6776d74de5b3d7aadafd3a6fb561576aabee46d6da9dfab94a6372 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:b25b07f3ca6776d74de5b3d7aadafd3a6fb561576aabee46d6da9dfab94a6372
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
