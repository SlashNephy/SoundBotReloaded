FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:873d0db3312a942fd77d99117d2dbfc7e38c8cf51ab3a2157aa98ec5e9197ad8 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:873d0db3312a942fd77d99117d2dbfc7e38c8cf51ab3a2157aa98ec5e9197ad8
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
