FROM --platform=$TARGETPLATFORM node:22.17.1-bullseye-slim@sha256:741a60f76e79ab4080ebb10d24ec0c2aa4527fc44e33a8d609c416cc351b4fff AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.17.1-bullseye-slim@sha256:741a60f76e79ab4080ebb10d24ec0c2aa4527fc44e33a8d609c416cc351b4fff
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
