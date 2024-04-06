FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:b307acadb845540961fa70ac4ca060390f0c33375ad7705943310d25c6f87d32 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:b307acadb845540961fa70ac4ca060390f0c33375ad7705943310d25c6f87d32
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
