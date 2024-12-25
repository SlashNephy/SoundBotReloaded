FROM --platform=$TARGETPLATFORM node:22.12.0-bullseye-slim@sha256:52e4282a01d63eb4cfce7a395364d366cee488c278079110d3aa49dd21b2bf18 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.12.0-bullseye-slim@sha256:52e4282a01d63eb4cfce7a395364d366cee488c278079110d3aa49dd21b2bf18
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
