FROM --platform=$TARGETPLATFORM node:22.18.0-bullseye-slim@sha256:6a1fddcac8be3a4fb41fdce952468a5aad23f80d1969eb6be5df87f72d7bc114 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.18.0-bullseye-slim@sha256:6a1fddcac8be3a4fb41fdce952468a5aad23f80d1969eb6be5df87f72d7bc114
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
