FROM --platform=$TARGETPLATFORM node:22.15.1-bullseye-slim@sha256:095b5c1684b260da1069dccca7aa373f67d0a20751cf70d2658f3b3e540b2c67 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.15.1-bullseye-slim@sha256:095b5c1684b260da1069dccca7aa373f67d0a20751cf70d2658f3b3e540b2c67
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
