FROM --platform=$TARGETPLATFORM node:19.7.0-bullseye-slim@sha256:424dd181b3be2a7aec23f6ba3b69e732745bad42e9b8a473efcb1399e76f12de AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:19.7.0-bullseye-slim@sha256:424dd181b3be2a7aec23f6ba3b69e732745bad42e9b8a473efcb1399e76f12de
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
