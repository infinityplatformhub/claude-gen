# Node.js / Express Backend Rules

---

## Project Structure

```
backend/
├── src/
│   ├── index.ts              entry point — wire dependencies, start server
│   ├── config.ts             settings (from env vars)
│   ├── routes/               route definitions (thin — delegate to services)
│   ├── controllers/          request handlers (parse input, call service, respond)
│   ├── services/             business logic
│   ├── repositories/         database access layer
│   ├── middleware/            auth, logging, error handling, validation
│   ├── types/                TypeScript interfaces and types
│   └── utils/                pure helper functions
├── migrations/               database migrations (Prisma, Knex, or raw SQL)
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
└── tsconfig.json
```

Controllers are thin — all business logic in services.

---

## Express Patterns

```typescript
// Routes are thin — delegate to controllers
// routes/users.ts
import { Router } from 'express'
import { UserController } from '../controllers/user.controller'

const router = Router()
const controller = new UserController()

router.get('/', controller.list)
router.get('/:id', controller.getById)
router.post('/', validateBody(CreateUserSchema), controller.create)

export default router
```

```typescript
// Controllers parse input + call services
// controllers/user.controller.ts
export class UserController {
    constructor(private service = new UserService()) {}

    list = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const users = await this.service.findAll()
            res.json({ data: users })
        } catch (err) {
            next(err)
        }
    }
}
```

---

## Error Handling

```typescript
// Custom error class — never throw generic Error
export class AppError extends Error {
    constructor(
        public code: string,
        public message: string,
        public statusCode: number = 400,
    ) {
        super(message)
    }
}

// Global error middleware (MUST be last middleware)
export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
    if (err instanceof AppError) {
        return res.status(err.statusCode).json({
            code: err.code,
            message: err.message,
        })
    }
    // Unknown errors — log full error, return generic message
    logger.error({ err }, 'unhandled error')
    res.status(500).json({ code: 'INTERNAL_ERROR', message: 'Something went wrong' })
}
```

---

## Repository Pattern

```typescript
export class UserRepository {
    constructor(private db: PrismaClient) {}

    async findById(id: string): Promise<User | null> {
        return this.db.user.findUnique({ where: { id } })
    }

    async create(data: CreateUserInput): Promise<User> {
        return this.db.user.create({ data })
    }
}
```

---

## Config

```typescript
// Use typed config — never process.env in business logic
interface Config {
    port: number
    dbUrl: string
    jwtSecret: string
    env: 'development' | 'production' | 'test'
}

function loadConfig(): Config {
    return {
        port: parseInt(process.env.APP_PORT || '8080', 10),
        dbUrl: requireEnv('DATABASE_URL'),
        jwtSecret: requireEnv('JWT_SECRET'),
        env: (process.env.NODE_ENV || 'development') as Config['env'],
    }
}

function requireEnv(key: string): string {
    const value = process.env[key]
    if (!value) throw new Error(`Missing required env var: ${key}`)
    return value
}
```

---

## Middleware Chain

```typescript
// Order matters:
app.use(helmet())                    // security headers
app.use(cors({ origin: config.corsOrigin }))
app.use(express.json({ limit: '10mb' }))
app.use(requestLogger)               // structured logging
app.use('/api', authMiddleware)       // auth check
app.use('/api/users', userRoutes)     // routes
app.use(errorHandler)                 // MUST be last
```

---

## Logging

```typescript
import pino from 'pino'

export const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    transport: process.env.NODE_ENV === 'development'
        ? { target: 'pino-pretty' }
        : undefined,
})

// Structured logging — never console.log in production
logger.info({ userId, latencyMs }, 'operation complete')

// Never log sensitive data: API keys, tokens, passwords
```

---

## Testing

```typescript
// Use Vitest or Jest + supertest for HTTP tests
import { describe, it, expect } from 'vitest'
import request from 'supertest'
import { app } from '../src/app'

describe('GET /api/health', () => {
    it('returns 200 with status ok', async () => {
        const res = await request(app).get('/api/health')
        expect(res.status).toBe(200)
        expect(res.body.status).toBe('ok')
    })
})

// Mock external services — never call real in tests
// Use factory functions for test data
// Run: vitest --coverage
```

---

## TypeScript Config

```
- Use strict mode: "strict": true
- Use ESM imports: "module": "ESNext", "moduleResolution": "bundler"
- Use path aliases: "@/": ["src/"]
- Target: ES2022+ (supports Node 18+)
```

---

## Forbidden Patterns

- No `any` TypeScript type — always explicit types
- No `require()` — use ESM `import`
- No `console.log` in production — use structured logger
- No `process.env` in business logic — use config object
- No callback-style code — use async/await
- No synchronous I/O in request handlers (`fs.readFileSync`, etc.)
- No inline SQL strings — use ORM or parameterized queries
- No `var` — use `const` or `let`
- No hardcoded secrets — use environment variables
