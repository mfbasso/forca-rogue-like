FROM node:20-alpine

WORKDIR /app
COPY . /app

RUN apk add --no-cache make bash love zip && make build && make lovejs

EXPOSE 8080

CMD ["npx", "node", "/app/web/server.js"]
