FROM --platform=$TARGETPLATFORM node:24.11.0-bullseye-slim@sha256:b613e20de4ff20e17847cf7d76fa19439a6da9181e1be501b3e9fbb347912ebd AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.11.0-bullseye-slim@sha256:b613e20de4ff20e17847cf7d76fa19439a6da9181e1be501b3e9fbb347912ebd
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
