# syntax=docker/dockerfile:1

# ---- Builder stage: installs dependencies (canvas needs native build tools) ----
FROM node:22-bookworm-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ pkg-config \
    libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpixman-1-dev \
    && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- Runtime stage ----
FROM node:22-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

# Runtime shared libraries required by node-canvas
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libjpeg62-turbo libgif7 librsvg2-2 libpixman-1-0 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 1001 nodejs \
    && useradd --system --uid 1001 --gid nodejs --home /app botuser

COPY --from=builder /app/node_modules ./node_modules
COPY . .

RUN chown -R botuser:nodejs /app && chmod +x entrypoint.sh
USER botuser

ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "index.js"]
