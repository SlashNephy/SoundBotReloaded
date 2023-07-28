FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:b5c6acf736d668e4f07fdb5c24365264bce24566e5da2fd8e9893d7d378bad05 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:b5c6acf736d668e4f07fdb5c24365264bce24566e5da2fd8e9893d7d378bad05
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
