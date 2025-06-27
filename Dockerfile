FROM --platform=$TARGETPLATFORM node:22.17.0-bullseye-slim@sha256:98663a445a21da13827b841d8df7b4d8743d5133e0d7a4e28ec0852140aa1abe AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.17.0-bullseye-slim@sha256:98663a445a21da13827b841d8df7b4d8743d5133e0d7a4e28ec0852140aa1abe
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
