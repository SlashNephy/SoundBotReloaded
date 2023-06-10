FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:f5fb074ab3704327ec9e406938ad2ed64e83ef292db3cac35e3794490d01c7bf AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.3.0-bullseye-slim@sha256:f5fb074ab3704327ec9e406938ad2ed64e83ef292db3cac35e3794490d01c7bf
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
