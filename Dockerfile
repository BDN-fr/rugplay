# syntax = docker/dockerfile:1
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-slim AS base-node
WORKDIR /app
ENV NODE_ENV="production"
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    node-gyp \
    pkg-config \
    python-is-python3 \
    curl \
    ca-certificates \
    unzip \
    libc6 \
    && rm -rf /var/lib/apt/lists/*

FROM base-node AS build-main
ARG REDIS_URL
ARG OPENROUTER_API_KEY
ARG PUBLIC_B2_ENDPOINT
ARG PUBLIC_B2_BUCKET
ARG PUBLIC_WEBSOCKET_URL
ARG DATABASE_URL
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB
ARG PRIVATE_BETTER_AUTH_SECRET
ARG PUBLIC_BETTER_AUTH_URL
ARG GOOGLE_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET
ARG PRIVATE_B2_KEY_ID
ARG PRIVATE_B2_APP_KEY
ARG PUBLIC_B2_REGION
ARG DISCORD_CLIENT_ID
ARG DISCORD_CLIENT_SECRET

# Copy package files
COPY website/package.json website/package-lock.json* ./

# Install dependencies with platform-specific binaries
RUN npm install --include=dev --platform=linux --arch=x64

# Copy the rest of the application
COPY website/. .

# Create .svelte-kit directory if it doesn't exist
RUN mkdir -p .svelte-kit

ENV REDIS_URL ${REDIS_URL}
ENV OPENROUTER_API_KEY ${OPENROUTER_API_KEY}
ENV PUBLIC_B2_ENDPOINT ${PUBLIC_B2_ENDPOINT}
ENV PUBLIC_B2_BUCKET ${PUBLIC_B2_BUCKET}
ENV PUBLIC_WEBSOCKET_URL ${PUBLIC_WEBSOCKET_URL}
ENV DATABASE_URL ${DATABASE_URL}
ENV POSTGRES_USER ${POSTGRES_USER}
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD}
ENV POSTGRES_DB ${POSTGRES_DB}
ENV PRIVATE_BETTER_AUTH_SECRET ${PRIVATE_BETTER_AUTH_SECRET}
ENV PUBLIC_BETTER_AUTH_URL ${PUBLIC_BETTER_AUTH_URL}
ENV GOOGLE_CLIENT_ID ${GOOGLE_CLIENT_ID}
ENV GOOGLE_CLIENT_SECRET ${GOOGLE_CLIENT_SECRET}
ENV PRIVATE_B2_KEY_ID ${PRIVATE_B2_KEY_ID}
ENV PRIVATE_B2_APP_KEY ${PRIVATE_B2_APP_KEY}
ENV PUBLIC_B2_REGION ${PUBLIC_B2_REGION}
ENV DISCORD_CLIENT_ID ${DISCORD_CLIENT_ID}
ENV DISCORD_CLIENT_SECRET ${DISCORD_CLIENT_SECRET}

RUN env

# Generate SvelteKit types and build
RUN npm run build

FROM base-node AS build-websocket
WORKDIR /websocket
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"
COPY website/websocket/package.json website/websocket/bun.lock* ./
COPY website/websocket/tsconfig.json ./
RUN bun install
COPY website/websocket/src ./src/
RUN bun build src/main.ts --outdir dist --target bun

FROM base-node AS production-main
COPY --from=build-main --chown=node:node /app/build ./build
COPY --from=build-main --chown=node:node /app/node_modules ./node_modules
COPY --from=build-main --chown=node:node /app/package.json ./package.json
USER node
EXPOSE 3000
CMD ["node", "build"]

FROM oven/bun:1 AS production-websocket
WORKDIR /websocket
COPY --from=build-websocket --chown=bun:bun /websocket/dist ./dist
COPY --from=build-websocket --chown=bun:bun /websocket/package.json ./package.json
USER bun
EXPOSE 8080
CMD ["bun", "run", "dist/main.js"]
