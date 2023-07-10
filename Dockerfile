FROM --platform=$TARGETPLATFORM node:20.4.0-bullseye-slim@sha256:efc09b6c3a307f8315b53cfea8189d6394a191ea825bdc8c40aa8424525390b7 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.4.0-bullseye-slim@sha256:efc09b6c3a307f8315b53cfea8189d6394a191ea825bdc8c40aa8424525390b7
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
