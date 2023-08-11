FROM --platform=$TARGETPLATFORM node:20.5.1-bullseye-slim@sha256:a2fe8fd3975d4b378abf721519df7cf0d465b8b8fb29e6bbe4d4a79c871bcded AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.1-bullseye-slim@sha256:a2fe8fd3975d4b378abf721519df7cf0d465b8b8fb29e6bbe4d4a79c871bcded
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
