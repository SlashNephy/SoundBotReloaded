FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:16b5468c330ca8cb67eef377de5ecc5bc879b55da3ac452f2e0cfb982241793a AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:16b5468c330ca8cb67eef377de5ecc5bc879b55da3ac452f2e0cfb982241793a
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
