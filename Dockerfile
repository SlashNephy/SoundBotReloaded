FROM --platform=$TARGETPLATFORM node:20.5.1-bullseye-slim@sha256:6a0c42361d113961655d13f4e5accd26cf2424b9652272a73ab25098718e25be AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.1-bullseye-slim@sha256:6a0c42361d113961655d13f4e5accd26cf2424b9652272a73ab25098718e25be
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
