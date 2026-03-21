# Python / Django Backend Rules

---

## Project Structure

```
project/
├── config/
│   ├── settings/              base.py, development.py, production.py
│   ├── urls.py                root URL conf
│   └── wsgi.py / asgi.py
├── apps/<app_name>/
│   ├── models.py              ORM models
│   ├── views.py               thin views (CBV or FBV)
│   ├── serializers.py         DRF serializers
│   ├── services.py            business logic
│   ├── selectors.py           read-only query logic
│   ├── permissions.py         custom DRF permissions
│   └── tests/                 test_services.py, factories.py
├── manage.py
└── pyproject.toml
```

---
## View Patterns

```python
# CBVs (ViewSets) for standard CRUD — less boilerplate
class ItemViewSet(viewsets.ModelViewSet):
    serializer_class = ItemSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        return item_selectors.get_visible_items(self.request.user)
    def perform_create(self, serializer):
        item_services.create_item(serializer.validated_data, user=self.request.user)

# FBVs with @api_view for one-off endpoints or webhooks
@api_view(["POST"])
def trigger_export(request):
    export_services.start_export(request.user, request.data)
    return Response({"status": "started"}, status=202)
```

---
## Models & ORM

```python
class Item(models.Model):
    slug = models.SlugField(max_length=120, unique=True)
    owner = models.ForeignKey("users.User", on_delete=models.CASCADE, related_name="items")
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.DRAFT)
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["status", "created_at"])]

class ItemQuerySet(models.QuerySet):
    def published(self):
        return self.filter(status=Status.PUBLISHED)
# Always use select_related / prefetch_related to avoid N+1
```

---
## DRF Patterns

```python
class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["id", "slug", "status", "created_at"]
        read_only_fields = ["id", "created_at"]

router = DefaultRouter()  # register ViewSets — never hand-wire CRUD URLs
router.register("items", ItemViewSet, basename="items")

class IsOwner(permissions.BasePermission):  # small, single-purpose
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user
```

---
## Error Handling

```python
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int = 400):
        self.code = code; self.message = message; self.status = status

# Register in REST_FRAMEWORK["EXCEPTION_HANDLER"]
def custom_handler(exc, context):
    if isinstance(exc, AppError):
        return Response({"code": exc.code, "message": exc.message}, status=exc.status)
    return default_exception_handler(exc, context)
# All errors return: {"code": "NOT_FOUND", "message": "Item not found"}
```

---
## Config & Async

```python
# Use django-environ or pydantic-settings — never os.getenv() in app code
import environ
env = environ.Env()
SECRET_KEY = env("DJANGO_SECRET_KEY")
DATABASES = {"default": env.db("DATABASE_URL")}

# Django 5.0+ async views — use for I/O-heavy endpoints only
async def dashboard_data(request):
    stats, alerts = await asyncio.gather(
        StatsService.fetch_async(), AlertService.fetch_async())
    return JsonResponse({"stats": stats, "alerts": alerts})
# Prefer sync views for ORM reads — async ORM is opt-in
# Never call sync ORM in async views without sync_to_async
```

---
## Testing

```python
# pytest-django + factory_boy — never hand-craft fixture data
class ItemFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Item
    slug = factory.Sequence(lambda n: f"item-{n}")
    owner = factory.SubFactory(UserFactory)

def test_create_item(api_client, user):
    api_client.force_authenticate(user)
    resp = api_client.post("/api/items/", {"slug": "new-item"})
    assert resp.status_code == 201
# Mock external services — never call real APIs in tests
```

---
## Logging

```python
import structlog
logger = structlog.get_logger()
logger.info("item_created", item_id=item.id, user_id=user.id)
# Never print(). Never log passwords, tokens, PII.
```

---
## Forbidden Patterns

- No business logic in views — delegate to services
- No raw SQL without written justification
- No `import *`
- No mutable default arguments
- No signals for business logic (use services)
- No `print()` — use structlog
- No bare `except:` without re-raise
- No `os.getenv()` — use settings
- No secrets in code
- No `time.sleep()` in async views
- No fat models — logic goes in services
