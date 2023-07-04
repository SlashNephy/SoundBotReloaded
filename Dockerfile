FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:57ae74ffd7253c71b6e896ae585184d26446ba10e689a02921a1852d24d82d74 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:57ae74ffd7253c71b6e896ae585184d26446ba10e689a02921a1852d24d82d74
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
