# ---------- Build ----------
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build || true

# ---------- Runtime ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S app && adduser -S app -G app
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=build /app/dist ./dist 2>/dev/null || true
COPY --from=build /app/src ./src 2>/dev/null || true
USER app
EXPOSE 3000
CMD ["node", "src/server.js"]
