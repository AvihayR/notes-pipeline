#Stage 1 - Node build Image
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json .
RUN npm ci

COPY . .
RUN npm run build

# Stage 2 - Nginx Image
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
ENV API_URL=backend:8000

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]