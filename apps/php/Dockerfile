FROM php:8.3-cli-alpine

RUN addgroup -S app && adduser -S app -G app
USER app
WORKDIR /app
EXPOSE 3010
COPY router.php ./router.php
COPY public ./public
CMD ["php", "-S", "0.0.0.0:3010", "-t", "public", "router.php"]
