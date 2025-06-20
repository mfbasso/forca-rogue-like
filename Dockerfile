FROM node:20-alpine

WORKDIR /app
COPY . /app

RUN apk add --no-cache make bash love zip
RUN make lovejs
RUN cp web/server.js forca-rogue-like/server.js

EXPOSE 8080

CMD ["npx", "node", "/app/forca-rogue-like/server.js"]
