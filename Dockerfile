FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx static files
RUN rm -rf ./*

# Copia os arquivos do build para o nginx
COPY forca-rogue-like/ .
COPY forca-rogue-like.love ./game.love

# Adiciona configuração customizada do nginx
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
