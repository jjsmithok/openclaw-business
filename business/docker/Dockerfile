FROM node:22-alpine

# Install required dependencies
RUN apk add --no-cache \
    curl \
    git \
    bash \
    docker \
    openssl

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Create app directory
WORKDIR /app

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose gateway ports
EXPOSE 18789 18790

# Set environment variables
ENV OPENCLAW_PROFILE=default
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:18789/health || exit 1

# Start OpenClaw
ENTRYPOINT ["docker-entrypoint.sh"]
