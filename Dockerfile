FROM --platform=$TARGETPLATFORM node:20.6.0-bullseye-slim@sha256:b905764e7025655563028e985a8c5a88023e181645d28e2fc7cf73e32293dfda AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.6.0-bullseye-slim@sha256:b905764e7025655563028e985a8c5a88023e181645d28e2fc7cf73e32293dfda
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
