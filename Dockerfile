FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:f8ea799deb8274a7e32824b4713fe59bddc43efa3459d2bedef622b43c81f1ca AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.5.0-bullseye-slim@sha256:f8ea799deb8274a7e32824b4713fe59bddc43efa3459d2bedef622b43c81f1ca
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
