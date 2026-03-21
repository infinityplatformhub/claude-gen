# React / Next.js Frontend Rules

---

## File Structure

```
frontend/
├── src/
│   ├── app/                 Next.js app router (or pages/)
│   ├── components/          reusable UI components
│   │   └── ui/              base components (Button, Card, Badge...)
│   ├── hooks/               custom hooks (all state + API logic)
│   ├── types/               TypeScript types (mirror backend models)
│   ├── lib/                 utilities, API client, constants
│   └── styles/              global styles (minimal — use Tailwind)
```

Pages/routes are thin — all logic in hooks.

---

## Custom Hooks (State + API)

```typescript
// Pattern: useXxx.ts
// One hook per domain entity
export function useItems() {
    const [items, setItems] = useState<Item[]>([])
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)

    const fetchAll = useCallback(async () => {
        setLoading(true)
        try {
            const data = await api.get<Item[]>('/api/items')
            setItems(data)
        } catch (e) {
            setError(String(e))
        } finally {
            setLoading(false)
        }
    }, [])

    return { items, loading, error, fetchAll }
}
```

For server state, prefer React Query / TanStack Query:
```typescript
export function useItems() {
    return useQuery({
        queryKey: ['items'],
        queryFn: () => api.get<Item[]>('/api/items'),
    })
}
```

---

## TypeScript Types

```typescript
// types/xxx.ts — mirrors backend models
// Never use `any` — always define explicit interface
// Types MUST match backend field names
```

---

## API Client

```typescript
// lib/api.ts — thin wrapper over fetch
// Always use this, never raw fetch in components

class ApiClient {
    async get<T>(path: string): Promise<T> { ... }
    async post<T>(path: string, body: unknown): Promise<T> { ... }
    async put<T>(path: string, body: unknown): Promise<T> { ... }
    async delete(path: string): Promise<void> { ... }
}

export const api = new ApiClient()
```

---

## Component Conventions

```tsx
// Always functional components with TypeScript
// Props defined with interface
// Use React.FC only when needed (prefer plain function)

interface ItemCardProps {
    item: Item
    onDelete: (id: string) => void
}

export function ItemCard({ item, onDelete }: ItemCardProps) {
    return (
        // Always handle: loading, error, empty states
    )
}
```

---

## State Management

```
- Local state: useState
- Server state: React Query / TanStack Query
- Global client state: Zustand or Context (prefer Zustand for complex state)
- Form state: React Hook Form or similar
- URL state: useSearchParams
```

---

## Tailwind Conventions

```
- Use design tokens: text-sm, text-base, text-lg (never arbitrary px)
- Colors: use semantic classes (text-red-500 for error, text-green-500 for success)
- No custom CSS unless absolutely necessary — Tailwind utility-first
- Dark mode: use dark: prefix variants
- Responsive: mobile-first (sm: md: lg:)
```

---

## Forbidden Patterns

- No `any` TypeScript type
- No raw `fetch` in components — use API client
- No business logic in pages/routes — use hooks
- No inline styles — use Tailwind classes
- No class components — always functional
- No `console.log` committed to repo
- No hardcoded API URLs — use config/env
- No `useEffect` for data fetching — use React Query
- No prop drilling beyond 2 levels — use context or composition
