FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:6a5acd2aa7c8563139b73adb8c76e4a65d306118f494eb830f14a406fba33bca AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:24.11.1-bullseye-slim@sha256:6a5acd2aa7c8563139b73adb8c76e4a65d306118f494eb830f14a406fba33bca
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
