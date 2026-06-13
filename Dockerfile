# Force exact Flutter SDK version matching local to avoid dependency solving issues
FROM ghcr.io/cirruslabs/flutter:3.32.2 AS build

WORKDIR /app
COPY . .
# Fix potential git dubious ownership errors inside Docker
RUN git config --global --add safe.directory '*'

# Accept build arguments from Railway
ARG GEMINI_API_KEY
ARG HF_TOKEN
ARG GROQ_API_KEY

# Recreate the .env file so build_runner can bake the keys into envied.g.dart
RUN echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env
RUN echo "HF_TOKEN=$HF_TOKEN" >> .env
RUN echo "GROQ_API_KEY=$GROQ_API_KEY" >> .env

# Fetch dependencies and build the web app
RUN rm -f pubspec.lock && flutter pub get
RUN flutter pub run build_runner build --delete-conflicting-outputs
RUN flutter build web --release

# Serve with lightweight Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Railway dynamically assigns $PORT. The official nginx image automatically replaces ${PORT} in the template.
