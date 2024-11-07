FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:01e6d7155cfe9567294142e456da98864df32fd51e7d64ea04c1287b3fdc4bc5 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.11.0-bullseye-slim@sha256:01e6d7155cfe9567294142e456da98864df32fd51e7d64ea04c1287b3fdc4bc5
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
