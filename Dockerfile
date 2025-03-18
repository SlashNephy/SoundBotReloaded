FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:d69b7c7ea65e223e1837a03784c6caa987e50bd2f1fcc174156554adfbe7ca6e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:d69b7c7ea65e223e1837a03784c6caa987e50bd2f1fcc174156554adfbe7ca6e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
