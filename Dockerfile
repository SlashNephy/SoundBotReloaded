FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:55571ebc48f4dfecfb4d6ec0a056a042ac32ed1ebea44d0fedd78088709b9948 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:55571ebc48f4dfecfb4d6ec0a056a042ac32ed1ebea44d0fedd78088709b9948
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
