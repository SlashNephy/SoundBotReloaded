FROM --platform=$TARGETPLATFORM node:22.21.1-bullseye-slim@sha256:f6d3331d7454b8dd0afd4d027ef09ba0f5dd3ab94e15bc496c4f40cfca5bae32 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.21.1-bullseye-slim@sha256:f6d3331d7454b8dd0afd4d027ef09ba0f5dd3ab94e15bc496c4f40cfca5bae32
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
