FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:19db2806db9239702b0b1d8da1a84ac3b25a8e13f89b3ca61756faf7dd6b93f4 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:19db2806db9239702b0b1d8da1a84ac3b25a8e13f89b3ca61756faf7dd6b93f4
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
