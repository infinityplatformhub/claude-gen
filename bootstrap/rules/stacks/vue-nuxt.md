# Vue / Nuxt Frontend Rules

---

## File Structure

```
frontend/
├── pages/                 route pages (thin — just layout + composable)
├── components/            reusable UI components
│   └── ui/                base components (Button, Card, Badge, Table...)
├── composables/           all state + API logic lives here
├── types/                 TypeScript types (mirror backend models)
└── utils/                 pure helper functions
```

Pages are thin shells — all logic in composables.

---

## Composables (State + API)

```typescript
// Pattern: useXxx.ts
// One composable per domain entity
export function useItems() {
    const items = ref<Item[]>([])
    const loading = ref(false)
    const error = ref<string | null>(null)

    async function fetchAll() {
        loading.value = true
        try {
            items.value = await $api('/api/items')
        } catch (e) {
            error.value = String(e)
        } finally {
            loading.value = false
        }
    }

    return { items, loading, error, fetchAll }
}
```

### Registered Composables

<!-- Customize: add composables as you create them -->
| File | Purpose |
|------|---------|
| `useAuth.ts` | Login, logout, token management |

Add new composable to this list when created.

---

## TypeScript Types

```typescript
// frontend/types/xxx.ts — mirrors backend models
// Never use `any` — always define explicit interface
// Types MUST match backend field names (snake_case JSON tags)
```

---

## API Client

```typescript
// utils/api.ts — thin wrapper over $fetch
// Always use this, never raw $fetch in components

export async function $api<T>(path: string, options?: RequestInit): Promise<T> {
    const token = useAuth().token.value
    return $fetch<T>(`${baseURL}${path}`, {
        ...options,
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            ...options?.headers,
        },
    })
}
```

---

## Component Conventions

```vue
<script setup lang="ts">
// Always <script setup lang="ts">
// Props defined with defineProps<{}>()
// Emits defined with defineEmits<{}>()
// Never Options API
</script>

<template>
  <!-- Always use semantic HTML -->
  <!-- Never inline styles — Tailwind classes only -->
  <!-- Loading states always shown -->
  <!-- Empty states always handled -->
</template>
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
- No raw `$fetch` in pages or components — use `$api`
- No business logic in pages — use composables
- No inline styles — use Tailwind classes
- No Options API — always Composition API with `<script setup>`
- No `console.log` committed to repo
- No hardcoded API URLs — use composable `baseURL` from config
