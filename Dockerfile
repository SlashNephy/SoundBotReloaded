FROM --platform=$TARGETPLATFORM node:22.15.0-bullseye-slim@sha256:dc5b6461793b93115c5484d855d7ca3e49bdd0797c8fe977d80462b73da6b30a AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.15.0-bullseye-slim@sha256:dc5b6461793b93115c5484d855d7ca3e49bdd0797c8fe977d80462b73da6b30a
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
