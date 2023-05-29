FROM --platform=$TARGETPLATFORM node:20.2.0-bullseye-slim@sha256:dc1906714d1993d291e1e7b5f236291236b0a0b6dfacdb164e4a9ea44d09c52e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.2.0-bullseye-slim@sha256:dc1906714d1993d291e1e7b5f236291236b0a0b6dfacdb164e4a9ea44d09c52e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
