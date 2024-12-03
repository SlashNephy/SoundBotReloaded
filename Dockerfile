FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:afd1dbb68a39182739b3e018c0dbaac9fd84816311775b4e638fa8ecfe388523 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:afd1dbb68a39182739b3e018c0dbaac9fd84816311775b4e638fa8ecfe388523
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
