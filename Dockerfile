FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:c77336dd02a5ae20328ea1c33b9f648dbfc848080c8562d325304251a86faa08 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:21.7.2-bullseye-slim@sha256:c77336dd02a5ae20328ea1c33b9f648dbfc848080c8562d325304251a86faa08
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
