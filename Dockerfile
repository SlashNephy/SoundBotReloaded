FROM --platform=$TARGETPLATFORM node:24.12.0-bullseye-slim@sha256:99c26b45ed43541718e38d5778792f38c0f3655dd0e1415f24c61782a62b0a1a AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.12.0-bullseye-slim@sha256:99c26b45ed43541718e38d5778792f38c0f3655dd0e1415f24c61782a62b0a1a
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
