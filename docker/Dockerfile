FROM node:18-alpine

WORKDIR /app

# FIX: copy package files first so Docker can cache the npm install layer
COPY package*.json ./
RUN npm install --omit=dev

# Copy the rest of the source after installing deps
COPY . .

# FIX: expose the port the app listens on
EXPOSE 3000

# FIX: use non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

CMD ["npm", "start"]
