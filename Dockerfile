FROM --platform=$TARGETPLATFORM node:22.13.0-bullseye-slim@sha256:7e935963ae04467f1349e99e766c91265a2d053c108c2f3aafbe02115c68e44d AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.13.0-bullseye-slim@sha256:7e935963ae04467f1349e99e766c91265a2d053c108c2f3aafbe02115c68e44d
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
