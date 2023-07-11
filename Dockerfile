FROM --platform=$TARGETPLATFORM node:20.4.0-bullseye-slim@sha256:77360666adb6622d13d0f32786185b7ddc5e5cd4a9c4140097ee7fdd9b3db527 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.4.0-bullseye-slim@sha256:77360666adb6622d13d0f32786185b7ddc5e5cd4a9c4140097ee7fdd9b3db527
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
