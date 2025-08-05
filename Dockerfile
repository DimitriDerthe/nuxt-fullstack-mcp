# Optimized single-stage build for MCP Server
FROM node:20-alpine

WORKDIR /app

# Install pnpm and clean apk cache
RUN npm install -g pnpm@10.14.0 && \
    rm -rf /var/cache/apk/*

# Create nuxt user
RUN addgroup --system --gid 1001 nuxt && \
    adduser --system --uid 1001 nuxt

# Copy source code
COPY --chown=nuxt:nuxt . .

# Install dependencies, build, and clean up in one layer
RUN pnpm install --no-frozen-lockfile && \
    pnpm build && \
    rm -rf node_modules && \
    pnpm install --prod --no-frozen-lockfile --ignore-scripts && \
    rm -rf /root/.npm /root/.pnpm-store /tmp/* && \
    pnpm store prune

USER nuxt

# Expose port
EXPOSE 4000

ENV NODE_ENV=production
ENV PORT=4000
ENV HOST=0.0.0.0

# Start the MCP server
CMD ["pnpm", "play"]