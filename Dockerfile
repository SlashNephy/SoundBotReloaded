FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:ba5f9086411a1f5b7b8849c033321075d7143312ac3e1547132afd82de78219b AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:ba5f9086411a1f5b7b8849c033321075d7143312ac3e1547132afd82de78219b
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
