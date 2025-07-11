FROM ghcr.io/cirruslabs/flutter:3.32.5 AS build

WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .

ARG TARGET_MAIN
RUN flutter build web -t lib/${TARGET_MAIN}

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
