FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Accept build arguments from Railway
ARG GEMINI_API_KEY
ARG HF_TOKEN
ARG GROQ_API_KEY

# Recreate the .env file so build_runner can bake the keys into envied.g.dart
RUN echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env
RUN echo "HF_TOKEN=$HF_TOKEN" >> .env
RUN echo "GROQ_API_KEY=$GROQ_API_KEY" >> .env

# Fetch dependencies and build the web app
RUN flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
RUN flutter build web --release

# Serve with lightweight Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Railway provides $PORT at runtime. Inject it into nginx config and start the server.
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
