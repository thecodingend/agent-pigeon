## App Context

[Insert high level description of the app]

## Inertia Rails Stack

- **Frontend**: React with `@inertiajs/react` 3.0.3
- **Serialization**: Use explicit props via `render inertia: { key: value }`. `as_json` is optional and mainly useful when shaping or restricting complex Rails objects.
- **UI**: shadcn/ui adapted for Inertia. NEVER `react-hook-form`, `zod`, `FormField`, `FormItem`, or `FormMessage` — use Inertia `<Form>` with plain shadcn inputs.
- **Testing**: Minitest. Load `references/minitest.md` from `inertia-rails-testing` for assertions.
- **Architecture**: Server owns routing, data, and auth. React renders only. See `inertia-rails-architecture` for the decision matrix.

## Coding Style

- Prefer DHH-level review standards: simple code, clear intent, minimal indirection, and abstractions that earn their keep.
- Write idiomatic Ruby and favor Rails conventions over custom patterns.
- Prefer simple inlined solutions, especially when there are only a few cases. Helpers, service objects, presenters, decorators, concerns, form objects, and other abstractions are rarely necessary.
- Accept duplication when it keeps the code obvious. Do not extract for neatness alone.
- Use clear, conventional naming. Favor full words, positive names, standard Rails terms, and code that is immediately understandable.
- Comments should be rare. Add them only when intent is non-obvious, branching is dense, or a long method needs orientation.

## Review Handoff

- When changing multiple files, always include a short recommended review order in the final response so the diffs can be read in a sensible sequence.
- Prefer ordering files by how information or behavior flows through the feature, usually persistence or model changes first, then request or controller code, then pages or components, then tests.
- If there is no strong flow, fall back to the file order that makes the change easiest to understand from top to bottom.

## Rails Preferences

- Keep controllers thin, but allow controller-level code for request flow and controller-specific concerns. Do not push code out of controllers unless it materially improves clarity.
- For migrations and anything else Rails can generate, start with `rails generate` instead of creating files by hand. Generate first, then edit the generated files if the default output needs adjustment.
- Keep business logic in models by default. Fat models are acceptable.
- Prefer inline Active Record queries written idiomatically in Ruby. Extract scopes or query objects only when there is real reuse or a clear readability win.
- Compute summaries, sort keys, and other derived data at write time when that keeps reads simple, pageable, and cacheable.
- Prefer database constraints over Active Record validations unless the user needs a validation error to see.
- Use callbacks freely when they fit the model lifecycle naturally.
- Helpers are near-banned. Only introduce a helper when formatting or view logic is genuinely reused and improves clarity, and pass dependencies explicitly instead of reaching for ivars.
- Avoid defensive coding for known data shapes. If the app knows it has a string, use string methods directly instead of adding type guards.
- Prefer failing loudly over adding protection against programmer errors or impossible states.
- Avoid exception-heavy control flow. Do not add `begin`/`rescue` or similar handling unless the failure is expected and user-facing.
- Be explicit over clever. Prefer plain conditionals or named methods over metaprogramming when there are only a few variations.
- Use SQL only when Active Record is clearly not sufficient.

## React Preferences

- Prefer one page file owning most of the JSX. Do not split pages into components unless there is a real functional boundary, repeated UI, or a clearly separate responsibility.
- Prefer composing directly from shadcn primitives plus utility classes. Do not create wrapper components for styling alone.
- In Tailwind, do not use `space-*` utilities or margin classes for layout spacing. Use `gap` between siblings and padding on the parent or container instead.
- Keep client state minimal. Avoid `useEffect` unless synchronizing with an external system or handling something that truly requires it.
- Avoid generic hooks and premature component extraction. Duplication is usually acceptable.
- Use Inertia layout composition via static `layout`, for example:

```tsx
import Layout from './Layout'

const Welcome = ({ user }) => {
  return (
    <>
      <h1>Welcome</h1>
      <p>Hello {user.name}, welcome to your first Inertia app!</p>
    </>
  )
}

Welcome.layout = Layout

export default Welcome
```

## TypeScript Preferences

- Keep TypeScript strict and define types explicitly, especially for page props and server-provided data.
- Prefer clear explicit types over clever inference when explicit types improve readability.

## Testing Preferences

- Test critical behavior only. Every test should justify its existence.
- Prefer integration-style tests over heavily isolated unit tests.
- Avoid testing implementation details or reshaping the app for test convenience.
- Tests should be as clear and direct as the code they validate.
