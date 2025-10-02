FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:81eda6ed8790dcb00e2bafcff9affadee405851f1f5b1dd3004f940982133c76 AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:22.20.0-bullseye-slim@sha256:81eda6ed8790dcb00e2bafcff9affadee405851f1f5b1dd3004f940982133c76
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
