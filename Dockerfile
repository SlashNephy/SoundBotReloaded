FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:c5014e11f343e1b34962bd709e4269480b580c4c8d321a1b93eadde7bc833f87 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:c5014e11f343e1b34962bd709e4269480b580c4c8d321a1b93eadde7bc833f87
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
