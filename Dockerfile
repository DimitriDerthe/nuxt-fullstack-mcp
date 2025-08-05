# Optimized MCP Server - 179MB target
FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@10.14.0

# Copy source
COPY . .

# Build everything
RUN pnpm install --no-frozen-lockfile && \
    pnpm build

# Production stage
FROM node:20-alpine AS production

WORKDIR /app

# Install only pnpm (no npm cache)
RUN npm install -g pnpm@10.14.0 && \
    npm cache clean --force && \
    rm -rf /root/.npm

# Create user
RUN addgroup --system --gid 1001 nuxt && \
    adduser --system --uid 1001 nuxt

# Copy only essential built files
COPY --from=builder --chown=nuxt:nuxt /app/package.json ./
COPY --from=builder --chown=nuxt:nuxt /app/pnpm-workspace.yaml ./
COPY --from=builder --chown=nuxt:nuxt /app/packages/nuxt-mcp/package.json ./packages/nuxt-mcp/
COPY --from=builder --chown=nuxt:nuxt /app/packages/nuxt-mcp/dist ./packages/nuxt-mcp/dist/
COPY --from=builder --chown=nuxt:nuxt /app/packages/nuxt-mcp/playground ./packages/nuxt-mcp/playground/
COPY --from=builder --chown=nuxt:nuxt /app/packages/vite-plugin-mcp/package.json ./packages/vite-plugin-mcp/
COPY --from=builder --chown=nuxt:nuxt /app/packages/vite-plugin-mcp/dist ./packages/vite-plugin-mcp/dist/

# Install only runtime dependencies
RUN pnpm install --prod --no-frozen-lockfile --ignore-scripts --no-optional && \
    pnpm store prune && \
    rm -rf /root/.pnpm-store /root/.npm /tmp/* /var/cache/apk/* /usr/local/lib/node_modules/npm

USER nuxt

EXPOSE 4000

ENV NODE_ENV=production
ENV PORT=4000
ENV HOST=0.0.0.0

CMD ["pnpm", "play"]