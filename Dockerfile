FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:0623e75a4d1e0102343572b85bd3a00bed1f0d297c4f36daeb491d2b45dc62f7 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:0623e75a4d1e0102343572b85bd3a00bed1f0d297c4f36daeb491d2b45dc62f7
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
