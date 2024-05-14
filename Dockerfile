FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:332380f55d15ac48a594f91f1a24ab8d04189fb491090a65aefa57189beb600e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:332380f55d15ac48a594f91f1a24ab8d04189fb491090a65aefa57189beb600e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
