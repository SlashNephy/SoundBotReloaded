FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:c47d5e7a994ede82082b5775b8ac2df649ce8295b992f1d91d71c532b3404b12 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:c47d5e7a994ede82082b5775b8ac2df649ce8295b992f1d91d71c532b3404b12
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
