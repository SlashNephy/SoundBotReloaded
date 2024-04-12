FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:65881997e49f9118732af6e10e88cd6b632df8c8f1b0d47009c604103a46d955 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.3-bullseye-slim@sha256:65881997e49f9118732af6e10e88cd6b632df8c8f1b0d47009c604103a46d955
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
