---
name: docker
description: Docker + Compose — multi-service, healthcheck, multi-stage builds, dev/prod patterns.
metadata:
  version: "1.0.0"
  domain: infrastructure
  triggers: Docker, Dockerfile, docker-compose, container, image, build, deploy container
  role: specialist
  scope: implementation
  output-format: code
  related-skills: debugging
---

# Docker

Docker and Docker Compose best practices for development and production.

## Dockerfile Best Practices

### Multi-Stage Build (Go)

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server ./cmd/server

# Runtime stage
FROM alpine:3.19
RUN apk --no-cache add ca-certificates tzdata
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder /server /server
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/health || exit 1
ENTRYPOINT ["/server"]
```

### Multi-Stage Build (Node.js)

```dockerfile
# Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable && pnpm build

# Runtime
FROM node:20-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder /app/.output ./.output
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", ".output/server/index.mjs"]
```

### Multi-Stage Build (Python)

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
RUN addgroup --system app && adduser --system --group app
COPY --from=builder /install /usr/local
COPY . .
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Docker Compose Patterns

### Full Stack Development

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      - .:/app
      - /app/node_modules  # exclude node_modules from bind mount
    environment:
      - APP_ENV=development
      - DB_HOST=db
      - REDIS_URL=redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dev -d myapp_dev"]
      interval: 5s
      timeout: 3s
      retries: 5

  cache:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  pgdata:
```

### Hot Reload in Development

```yaml
# Dockerfile.dev (development only)
# Mount source code as volume for hot reload
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app           # bind mount for hot reload
    command: air          # Go: use air for hot reload
    # command: pnpm dev  # Node.js: use framework dev server
    # command: uvicorn app.main:app --reload  # Python: use --reload
```

## .dockerignore

```
.git
.gitignore
node_modules
__pycache__
*.pyc
.env
.env.local
*.md
!README.md
.vscode
.idea
tmp/
dist/
.output/
coverage/
```

## Health Checks

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
  interval: 30s    # how often to check
  timeout: 3s      # max time for single check
  retries: 3       # failures before unhealthy
  start_period: 10s # grace period on startup
```

## Networking

```yaml
services:
  # Services in the same compose file can reach each other by service name
  # app connects to db via: db:5432 (not localhost)
  app:
    environment:
      - DB_HOST=db        # service name = hostname
      - REDIS_URL=redis://cache:6379

  # Expose ports to host only when needed (dev tools, debugging)
  db:
    ports:
      - "5432:5432"       # host:container
```

## Security Checklist

- [ ] Run as non-root user (`USER app`)
- [ ] Use specific image tags, not `latest`
- [ ] No secrets in Dockerfile or docker-compose.yml
- [ ] Use `.dockerignore` to exclude sensitive files
- [ ] Scan images: `docker scout cves <image>`
- [ ] Use `--no-cache` for production builds
- [ ] Set resource limits in production

## Constraints

### MUST DO
- Use multi-stage builds for production images
- Run containers as non-root user
- Add health checks to all services
- Use `depends_on` with `condition: service_healthy`
- Pin image versions (e.g., `postgres:16-alpine`, not `postgres:latest`)
- Use `.dockerignore` to keep images small

### MUST NOT DO
- Store secrets in images or Dockerfiles
- Use `latest` tag in production
- Run as root in containers
- Skip health checks
- Use `docker-compose` (v1) — use `docker compose` (v2)
- Bind mount `node_modules` or `vendor` from host
