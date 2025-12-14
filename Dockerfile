FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:06dcbf086e70cc62e746f4a3e7617a5bc14e6e2f78cb86ad9e4baaf5aee4fa74 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:06dcbf086e70cc62e746f4a3e7617a5bc14e6e2f78cb86ad9e4baaf5aee4fa74
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
