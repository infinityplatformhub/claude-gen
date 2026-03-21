# PHP / Laravel Backend Rules

---

## Project Structure

```
app/
├── Http/
│   ├── Controllers/          thin — delegate to services/actions
│   ├── Requests/             form request validation
│   ├── Resources/            API resource transformers
│   └── Middleware/
├── Models/                   Eloquent models + scopes + relationships
├── Services/                 business logic (or Actions/)
├── Repositories/             database queries (optional, for complex apps)
├── Events/                   domain events
├── Listeners/                event handlers
├── Jobs/                     queue jobs
├── Policies/                 authorization
└── Exceptions/               custom exceptions
database/
├── migrations/               timestamp-based
├── seeders/
└── factories/                test data factories
tests/
├── Feature/                  HTTP + integration tests
└── Unit/                     isolated logic tests
```

---

## Controller Patterns

```php
// Controllers are THIN — delegate to services/actions
class OrderController extends Controller
{
    public function store(StoreOrderRequest $request, CreateOrderAction $action): JsonResponse
    {
        $order = $action->execute($request->validated());
        return OrderResource::make($order)->response()->setStatusCode(201);
    }
}

// Use Form Requests for validation — never validate in controllers
class StoreOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'product_id' => ['required', 'exists:products,id'],
            'quantity'    => ['required', 'integer', 'min:1'],
        ];
    }
}
```

---

## Eloquent Conventions

```php
// Always define fillable or guarded
protected $fillable = ['name', 'email', 'status'];

// Use scopes for reusable queries
public function scopeActive(Builder $query): Builder
{
    return $query->where('status', 'active');
}

// Eager load to prevent N+1
User::with(['posts', 'profile'])->get();       // GOOD
User::all()->map(fn($u) => $u->posts);         // BAD — N+1

// Use chunking for large datasets
User::chunk(1000, function ($users) {
    foreach ($users as $user) { ... }
});
```

---

## Service / Action Pattern

```php
// One action per use case — testable, reusable
class CreateOrderAction
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly PaymentService $payments,
    ) {}

    public function execute(array $data): Order
    {
        return DB::transaction(function () use ($data) {
            $order = $this->orders->create($data);
            $this->payments->charge($order);
            OrderCreated::dispatch($order);
            return $order;
        });
    }
}
```

---

## Error Handling

```php
// Custom exceptions with HTTP context
class InsufficientBalanceException extends HttpException
{
    public function __construct(float $balance, float $required)
    {
        parent::__construct(422, "Insufficient balance: {$balance} < {$required}");
    }
}

// Global handler returns consistent JSON
// app/Exceptions/Handler.php → render()
// {"message": "...", "errors": {...}}
```

---

## Authentication

```php
// Use Sanctum for API tokens
// Use Laravel Fortify or Breeze for web auth
// Never roll your own authentication

// Protect routes
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('orders', OrderController::class);
});

// Use Policies for authorization
$this->authorize('update', $order);
```

---

## Queue / Jobs

```php
// Jobs for anything that can be async
class ProcessPayment implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;

    public function handle(PaymentService $payments): void
    {
        $payments->process($this->order);
    }

    public function failed(Throwable $e): void
    {
        // Notify admin, log failure
    }
}
```

---

## Testing

```php
// Use Pest PHP (preferred) or PHPUnit
// Feature tests for HTTP endpoints
test('can create order', function () {
    $user = User::factory()->create();
    $product = Product::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/orders', [
            'product_id' => $product->id,
            'quantity'    => 2,
        ]);

    $response->assertStatus(201)
             ->assertJsonPath('data.quantity', 2);

    $this->assertDatabaseHas('orders', [
        'user_id'    => $user->id,
        'product_id' => $product->id,
    ]);
});

// Use factories for test data — never hardcode IDs
// Use RefreshDatabase trait for clean state
// Run: php artisan test --parallel
```

---

## Config & Environment

```php
// Always use config() helper — never env() outside config files
$url = config('services.payment.url');    // GOOD
$url = env('PAYMENT_URL');                // BAD in app code

// Config caching: php artisan config:cache
```

---

## Forbidden Patterns

- No business logic in Controllers — use Services/Actions
- No `env()` calls outside `config/` files
- No raw SQL string concatenation — use Eloquent/Query Builder
- No `dd()` or `dump()` committed to repo
- No mass assignment without `$fillable` or `$guarded`
- No N+1 queries — always eager load relationships
- No hardcoded secrets — use `.env` + `config()`
- No `sleep()` in request lifecycle — use queues
- No `@` error suppression operator
