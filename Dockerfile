FROM --platform=$TARGETPLATFORM node:20.6.1-bullseye-slim@sha256:ee905d8492c443aebe41f4cc525ebabefef757df43556c444be67391cc031cba AS cache
WORKDIR /app

COPY ./.yarn/ ./.yarn/
COPY ./package.json ./.yarnrc.yml ./yarn.lock ./
RUN yarn --immutable

FROM --platform=$TARGETPLATFORM node:20.6.1-bullseye-slim@sha256:ee905d8492c443aebe41f4cc525ebabefef757df43556c444be67391cc031cba
WORKDIR /app

COPY --from=cache /app/node_modules/ ./node_modules/
COPY ./ ./
RUN yarn build

ENTRYPOINT ["node", "./main.js"]
