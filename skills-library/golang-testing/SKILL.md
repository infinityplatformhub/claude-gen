---
name: golang-testing
description: Go testing — table-driven, testcontainers, mocks, benchmarks, fuzzing. Use when writing Go tests, setting up test infrastructure, or implementing testing best practices.
metadata:
  version: "1.0.0"
  domain: testing
  triggers: Go test, table-driven, testcontainers, mock, benchmark, fuzz, coverage
  role: specialist
  scope: implementation
  output-format: code
  related-skills: golang-pro
---

# Go Testing

Senior Go testing specialist. Covers table-driven tests, integration tests with testcontainers, mocking, benchmarks, and fuzz testing.

## Core Workflow

1. **Understand the code under test** — read interfaces, dependencies, side effects
2. **Choose test type** — unit (isolated), integration (real deps), benchmark (perf)
3. **Write tests** — table-driven with subtests, clear names, edge cases
4. **Run with race detector** — always `go test -race ./...`
5. **Check coverage** — `go test -coverprofile=coverage.out ./...`

## Table-Driven Tests

```go
func TestParseAmount(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr bool
    }{
        {name: "valid integer", input: "100", want: 100},
        {name: "valid with cents", input: "10.50", want: 1050},
        {name: "empty string", input: "", wantErr: true},
        {name: "negative", input: "-5", want: -500},
        {name: "invalid chars", input: "abc", wantErr: true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseAmount(tt.input)
            if tt.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got != tt.want {
                t.Errorf("ParseAmount(%q) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

## Testcontainers (Integration Tests)

```go
func TestUserRepo_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }

    ctx := context.Background()

    // Start PostgreSQL container
    pgContainer, err := postgres.Run(ctx,
        "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready").
                WithOccurrence(2).
                WithStartupTimeout(5*time.Second),
        ),
    )
    if err != nil {
        t.Fatal(err)
    }
    defer pgContainer.Terminate(ctx)

    connStr, _ := pgContainer.ConnectionString(ctx, "sslmode=disable")
    db := setupGORM(t, connStr)

    repo := NewUserRepo(db)

    t.Run("create and find", func(t *testing.T) {
        user := &User{Name: "Alice", Email: "alice@test.com"}
        err := repo.Create(ctx, user)
        if err != nil {
            t.Fatalf("create: %v", err)
        }

        found, err := repo.FindByID(ctx, user.ID)
        if err != nil {
            t.Fatalf("find: %v", err)
        }
        if found.Email != user.Email {
            t.Errorf("email = %q, want %q", found.Email, user.Email)
        }
    })
}
```

## Mocking with Interfaces

```go
// Define interface in the consumer package
type UserStore interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// Mock implementation for tests
type mockUserStore struct {
    findFn func(ctx context.Context, id string) (*User, error)
    saveFn func(ctx context.Context, user *User) error
}

func (m *mockUserStore) FindByID(ctx context.Context, id string) (*User, error) {
    return m.findFn(ctx, id)
}

func (m *mockUserStore) Save(ctx context.Context, user *User) error {
    return m.saveFn(ctx, user)
}
```

## Benchmarks

```go
func BenchmarkHashPassword(b *testing.B) {
    password := "test-password-123"
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        HashPassword(password)
    }
}

func BenchmarkLookup(b *testing.B) {
    data := generateTestData(10000)

    b.Run("map", func(b *testing.B) {
        m := buildMap(data)
        b.ResetTimer()
        for i := 0; i < b.N; i++ {
            _ = m["key-5000"]
        }
    })

    b.Run("slice-scan", func(b *testing.B) {
        b.ResetTimer()
        for i := 0; i < b.N; i++ {
            linearSearch(data, "key-5000")
        }
    })
}
```

## Fuzz Testing (Go 1.18+)

```go
func FuzzParseJSON(f *testing.F) {
    // Seed corpus
    f.Add([]byte(`{"name": "test"}`))
    f.Add([]byte(`{}`))
    f.Add([]byte(`null`))

    f.Fuzz(func(t *testing.T, data []byte) {
        var result map[string]any
        err := json.Unmarshal(data, &result)
        if err != nil {
            return // invalid JSON is expected
        }
        // Re-marshal should not panic
        _, err = json.Marshal(result)
        if err != nil {
            t.Errorf("marshal after unmarshal failed: %v", err)
        }
    })
}
```

## HTTP Handler Testing

```go
func TestHealthHandler(t *testing.T) {
    handler := NewHealthHandler()

    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    rec := httptest.NewRecorder()

    handler.ServeHTTP(rec, req)

    if rec.Code != http.StatusOK {
        t.Errorf("status = %d, want %d", rec.Code, http.StatusOK)
    }

    var body map[string]string
    json.NewDecoder(rec.Body).Decode(&body)
    if body["status"] != "ok" {
        t.Errorf("body status = %q, want %q", body["status"], "ok")
    }
}
```

## Constraints

### MUST DO
- Use table-driven tests with `t.Run()` subtests
- Run with `-race` flag in CI and locally
- Use `testing.Short()` to skip slow integration tests
- Clean up test resources (containers, temp files, DB records)
- Test error paths, not just happy paths
- Use `t.Helper()` in test helper functions
- Name tests descriptively: `TestFunction_Scenario_ExpectedResult`

### MUST NOT DO
- Skip the race detector
- Use `time.Sleep()` for synchronization — use channels or sync primitives
- Leave test containers running (always `defer Terminate()`)
- Test private functions directly — test through public API
- Use `os.Exit()` in tests — use `t.Fatal()`
- Ignore flaky tests — fix the root cause
