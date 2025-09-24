FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:39a8664a9388d7637e56e87dded1be09b8d2b6b62cd263571dedc5d76d4aba70 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:39a8664a9388d7637e56e87dded1be09b8d2b6b62cd263571dedc5d76d4aba70
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
