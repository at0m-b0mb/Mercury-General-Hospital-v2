FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application files
COPY server.js ./
COPY data/ ./data/
COPY public/ ./public/

# Default to port 80 inside the container
# Map to a host port with: docker run -p 8080:80 ...
ENV PORT=80
EXPOSE 80

# Run as non-root user for better security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

CMD ["node", "server.js"]
