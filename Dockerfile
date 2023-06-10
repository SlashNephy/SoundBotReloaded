FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:f52e0eb0f31863051b56d76d191b283c2b49ac084762eddfeb1afb54791b250b AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:f52e0eb0f31863051b56d76d191b283c2b49ac084762eddfeb1afb54791b250b
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
