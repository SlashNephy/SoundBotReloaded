FROM --platform=$BUILDPLATFORM node:18.4.0-bullseye-slim AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$BUILDPLATFORM node:18.4.0-bullseye-slim AS build
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

FROM --platform=$TARGETPLATFORM node:18.4.0-bullseye-slim AS runtime
ENV NODE_ENV="production"
ENV PORT=3000
WORKDIR /app
USER node

COPY --from=build /app/package.json /app/main.js ./
COPY --from=build /app/lib/ ./lib/

ENTRYPOINT ["npm", "main.js"]
