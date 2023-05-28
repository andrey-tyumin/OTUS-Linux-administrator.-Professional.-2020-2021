FROM nginx:alpine
RUN apk update && apk upgrade
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
