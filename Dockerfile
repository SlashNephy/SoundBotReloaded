FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:7ed5bbd6c552d2a8f83c24620c68e88f4299980214d89bc1f39c46bfa80b1ec7 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.14.0-bullseye-slim@sha256:7ed5bbd6c552d2a8f83c24620c68e88f4299980214d89bc1f39c46bfa80b1ec7
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
