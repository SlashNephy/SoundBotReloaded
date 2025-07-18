FROM --platform=$TARGETPLATFORM node:22.17.1-bullseye-slim@sha256:c913ded7281627117bd2e2afbe955036c9ff780eff28f4058e535cd6a5151e26 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.17.1-bullseye-slim@sha256:c913ded7281627117bd2e2afbe955036c9ff780eff28f4058e535cd6a5151e26
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
