# Nuxt MCP Server - Simple Production Image
FROM node:20-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@10.14.0

# Copy source code
COPY . .

# Install dependencies and build
RUN pnpm install --no-frozen-lockfile
RUN pnpm build

# Create nuxt user
RUN addgroup --system --gid 1001 nuxt
RUN adduser --system --uid 1001 nuxt

# Change ownership
RUN chown -R nuxt:nuxt /app

USER nuxt

# Expose port
EXPOSE 4000

ENV NODE_ENV=production
ENV PORT=4000
ENV HOST=0.0.0.0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Start the MCP server (playground as example)
CMD ["pnpm", "play"]