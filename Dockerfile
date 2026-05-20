FROM nginx:1.27-alpine

RUN sed -i 's/listen       80;/listen       30080;/g' /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 30080
