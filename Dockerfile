cat > Dockerfile << 'EOF'
# ---------- Runtime ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -S app && adduser -S app -G app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

RUN chown -R app:app /app
USER app

EXPOSE 3000
CMD ["node", "src/server.js"]
EOF
