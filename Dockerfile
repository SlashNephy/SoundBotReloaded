FROM --platform=$TARGETPLATFORM node:22.13.0-bullseye-slim@sha256:325ce775e38a3960fb5492eed4fc60bd86d48ec026e62ce73828081738de8e6b AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.13.0-bullseye-slim@sha256:325ce775e38a3960fb5492eed4fc60bd86d48ec026e62ce73828081738de8e6b
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
