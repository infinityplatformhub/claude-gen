# Python / FastAPI Backend Rules

---

## Project Structure

```
backend/
├── app/
│   ├── main.py              entry point
│   ├── config.py            settings (pydantic-settings)
│   ├── models/              SQLAlchemy / Pydantic models
│   ├── routes/              API route handlers (thin)
│   ├── services/            business logic
│   ├── repositories/        database access layer
│   └── middleware/           auth, logging, error handling
├── migrations/              Alembic migrations
├── tests/
│   ├── unit/
│   └── integration/
├── pyproject.toml
└── requirements.txt or uv.lock
```

---

## Framework Patterns

### FastAPI
```python
# Routes are thin — delegate to services
@router.post("/items", response_model=ItemResponse, status_code=201)
async def create_item(
    payload: ItemCreate,
    service: ItemService = Depends(get_item_service),
):
    return await service.create(payload)
```

### Django
```python
# Views delegate to services, not direct ORM calls
class ItemViewSet(viewsets.ModelViewSet):
    def perform_create(self, serializer):
        ItemService.create(serializer.validated_data)
```

---

## Error Handling

```python
# Custom exception classes — never raise generic Exception
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int = 400):
        self.code = code
        self.message = message
        self.status = status

# Global exception handler returns consistent JSON
# {"code": "NOT_FOUND", "message": "Item not found"}
```

---

## Repository Pattern

```python
class ItemRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def find_by_id(self, item_id: str) -> Item | None:
        result = await self.db.execute(
            select(Item).where(Item.id == item_id)
        )
        return result.scalar_one_or_none()
```

---

## Config

```python
# Use pydantic-settings — never os.getenv() in business logic
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_env: str = "development"
    db_url: str
    jwt_secret: str

    class Config:
        env_prefix = "APP_"  # customize per project
```

---

## Async Rules

```python
# Use async/await for I/O-bound operations
# Never use sync calls in async context (blocks event loop)
# Use asyncio.gather() for parallel independent calls
# Always set timeouts on external HTTP calls
```

---

## Testing

```python
# Use pytest + pytest-asyncio
# Fixtures for DB setup/teardown
# Factory pattern for test data
# Mock external services — never call real in tests
# Run: pytest --cov --cov-report=term-missing
```

---

## Logging

```python
import structlog

logger = structlog.get_logger()

# Structured logging — never print() in production
logger.info("operation_complete", user_id=user_id, latency_ms=latency)

# Never log sensitive data: API keys, tokens, passwords
```

---

## Forbidden Patterns

- No `print()` in production code — use structured logging
- No bare `except:` or `except Exception:` without re-raise or specific handling
- No `os.getenv()` in business logic — use config class
- No SQL string concatenation — use parameterized queries
- No `import *`
- No mutable default arguments
- No `time.sleep()` in async code — use `asyncio.sleep()`
- No secrets in code — use environment variables
