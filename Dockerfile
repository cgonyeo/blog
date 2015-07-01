# A container for hosting Derek Gonyeo's blog
FROM nginx

MAINTAINER Derek Gonyeo

COPY _site /usr/share/nginx/html
