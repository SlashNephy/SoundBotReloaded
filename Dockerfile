FROM --platform=$TARGETPLATFORM node:24.11.0-bullseye-slim@sha256:61bfe4ca608025ed7da3575f66a11eaf76178b6f7e69607be88ca10ca0a94a22 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.11.0-bullseye-slim@sha256:61bfe4ca608025ed7da3575f66a11eaf76178b6f7e69607be88ca10ca0a94a22
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
