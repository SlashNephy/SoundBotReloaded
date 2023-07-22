FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:45dbc40906607e48873d26caa1a968f1a5187dd5e78e0e47205eea15393fd9c3 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:45dbc40906607e48873d26caa1a968f1a5187dd5e78e0e47205eea15393fd9c3
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
