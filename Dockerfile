FROM --platform=$TARGETPLATFORM node:22.16.0-bullseye-slim@sha256:a0368d5282fd3caa1cefd3fc38ba666f3fd42ac1ab3ecb312b76008fbe56e6a7 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.16.0-bullseye-slim@sha256:a0368d5282fd3caa1cefd3fc38ba666f3fd42ac1ab3ecb312b76008fbe56e6a7
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
