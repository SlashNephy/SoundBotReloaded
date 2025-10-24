FROM --platform=$TARGETPLATFORM node:22.21.0-bullseye-slim@sha256:3fb611e6440f371bfc7f7c78846661c54d5da98808d41c14a21a52ab7c3db9cd AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.21.0-bullseye-slim@sha256:3fb611e6440f371bfc7f7c78846661c54d5da98808d41c14a21a52ab7c3db9cd
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
