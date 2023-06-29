FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:115459129ed17d1c8c4a7911e7a3756c8e49b9d89e3eac48f34249578c9971ef AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.1-bullseye-slim@sha256:115459129ed17d1c8c4a7911e7a3756c8e49b9d89e3eac48f34249578c9971ef
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
