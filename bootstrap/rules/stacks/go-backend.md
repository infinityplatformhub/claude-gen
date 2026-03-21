# Go Backend Rules

---

## Package Structure

```
internal/         private packages — never import from outside
pkg/              reusable utilities — safe to import anywhere
cmd/server/       main entry point only — wire dependencies, start server
```

Never put business logic in `cmd/`. Wire only.

---

## Error Handling

```go
// Always wrap errors with context
if err != nil {
    return fmt.Errorf("service: failed to process: %w", err)
}

// HTTP handlers return consistent JSON errors
type APIError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}
// Use helper: respondError(w, http.StatusBadRequest, "INVALID_INPUT", "...")
// Never: w.Write([]byte("error"))
```

---

## HTTP Handlers

```go
// Pattern: handler receives dependencies via closure or struct
type Handler struct {
    service *core.Service
    logger  zerolog.Logger
}

// Always set request timeout
ctx, cancel := context.WithTimeout(r.Context(), 30*time.Second)
defer cancel()
```

---

## Repository Pattern

```go
// internal/store/repos/xxx_repo.go
type XxxRepo struct {
    db *gorm.DB
}

func NewXxxRepo(db *gorm.DB) *XxxRepo { return &XxxRepo{db: db} }

// All DB calls go through repo — never call db directly from handlers
// Use ctx everywhere for cancellation
func (r *XxxRepo) FindByID(ctx context.Context, id string) (*models.Xxx, error) {
    var m models.Xxx
    err := r.db.WithContext(ctx).First(&m, "id = ?", id).Error
    return &m, err
}
```

---

## Concurrency Rules

```go
// Use sync.Map for concurrent read-heavy maps
// Use atomic.Value for single-value hot-swap
// Use sync.RWMutex only for complex critical sections
// Always pass context — never use context.Background() in request flow
// Always set timeouts on external calls
```

---

## Logging

```go
// Use zerolog — structured, never fmt.Println in production code
log := logger.With().Str("component", "service").Logger()

log.Info().
    Str("user_id", userID).
    Int64("latency_ms", latency).
    Msg("operation complete")

// Never log sensitive data: API keys, tokens, passwords
```

---

## GORM Conventions

```go
// Always use soft delete (gorm.DeletedAt) for user-facing models
// Always pass ctx: db.WithContext(ctx)
// Use transactions for multi-table writes

tx := db.WithContext(ctx).Begin()
defer func() {
    if r := recover(); r != nil {
        tx.Rollback()
    }
}()
// ... do work ...
tx.Commit()
```

---

## Testing

```go
// Table-driven tests for pure functions
// Integration tests use real DB (testcontainers or test DB)
// Always run with -race flag
// Mock external services — never call real in tests
```

---

## Forbidden Patterns

- No `panic()` in production code (only in main for fatal startup errors)
- No `init()` functions (use explicit initialization)
- No global mutable state (use dependency injection)
- No direct `os.Getenv()` in internal packages — use config struct
- No `interface{}` / `any` — use typed structs
- No `time.Sleep()` in request handlers
- No goroutines without proper shutdown (use context cancellation)
