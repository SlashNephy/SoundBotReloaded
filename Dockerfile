FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:d634f3f7fd569adf841b8a8f73ad04a757ca7bbaf4b3c4c1163dcac3c064d3a5 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:d634f3f7fd569adf841b8a8f73ad04a757ca7bbaf4b3c4c1163dcac3c064d3a5
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
