FROM --platform=$TARGETPLATFORM node:20.8.0-bullseye-slim@sha256:ae31e40fdecf15751ee23055b60717e2ce6e03acc4ee7ffd8f87e76813d8010f AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.8.0-bullseye-slim@sha256:ae31e40fdecf15751ee23055b60717e2ce6e03acc4ee7ffd8f87e76813d8010f
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
