FROM --platform=$TARGETPLATFORM node:22.19.0-bullseye-slim@sha256:8efd3ed25d83b4328df873ed9853a5bd97ffce8eb3498785e45c3e7297571f0e AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.19.0-bullseye-slim@sha256:8efd3ed25d83b4328df873ed9853a5bd97ffce8eb3498785e45c3e7297571f0e
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
