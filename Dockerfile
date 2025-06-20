FROM node:20-alpine

WORKDIR /app
COPY . /app

RUN apk add --no-cache make bash love zip
RUN make build-love
RUN npx love.js forca-rogue-like.love forca-rogue-like -c -m 500000000 -t "Forca Rogue Like"
RUN cp web/server.js forca-rogue-like/server.js

EXPOSE 8080

CMD ["npx", "node", "/app/forca-rogue-like/server.js"]
