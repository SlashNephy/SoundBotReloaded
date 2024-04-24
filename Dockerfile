FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:788417c15fd7e0fde36a592e70c06fdb9b0a553733ad036e118ece9950d0d35e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:788417c15fd7e0fde36a592e70c06fdb9b0a553733ad036e118ece9950d0d35e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
