# Minima

Minimalist launcher with a grayscale (black and white) visual style and limited
access to entertainment apps.

## Vision

Minima is an Android launcher (and Windows app) that serves as a clean, focused
interface for managing tasks. It uses Notion as its primary database and works
offline-first: data is stored locally and syncs with Notion when a connection
is available.

## Architecture

### Pattern: CRUD + Sync Queue

- **Local SQLite** (drift) as the primary and immediate data store.
- **Sync queue**: each local change is marked as pending (`dirty flag`).
- **Bidirectional sync with Notion**: on reconnect, push local changes and pull
  remote changes.
- **Conflict resolution**: last-write-wins (personal tool, single user).

### Structure: Single Flutter Monorepo

```
lib/
  domain/          # Entities, value objects, repository interfaces
  data/            # Implementations: SQLite (drift), Notion API, sync engine
    local/         # Drift database, DAOs
    remote/        # Notion API client
    sync/          # Sync queue, conflict resolution
  ui/              # Widgets, screens, theme
    theme/         # Grayscale palette, typography
    screens/       # Launcher screens
    widgets/       # Reusable components
  app.dart         # Entry point, dependency wiring
test/
  domain/
  data/
  ui/
```

### Entities (v1)

- **Task**: main task with title, status, priority.
- **Subtask**: subtask linked to a Task.

More entities will be added incrementally.

### Offline-First Flow

1. User creates/edits data -> immediate write to local SQLite.
2. The change is registered in the sync queue with a timestamp.
3. On connection detected: push local changes to Notion, pull remote changes.
4. Notion is the source of truth; SQLite is cache + offline store.

## Guidelines

Rules from `GUIDELINES.md` apply, with these additions:

### Naming

- `[Name]Manager` for business orchestrators (e.g. `TaskManager`)
- `[Name]Repository` for data access (abstract in domain, implemented in data)
- `[Name]Client` for external API clients (e.g. `NotionClient`)
- `SyncEngine` for the synchronization engine
- Entities: singular, one word (Task, Subtask)
- Value Objects: UniqueId, SyncStatus

### Code

- `dart format` as the formatter
- Immutability for value objects and models
- Manual dependency wiring (no service locator or unnecessary code generation)
- Tests for domain and data layers at minimum
- Do not add features, refactors, or improvements beyond what is requested
- Do not over-engineer: the simplest solution that works

### Sync

- The Notion API has rate limits (~3 requests/second). The sync engine must
  respect this with batching and backoff.
- Each local record has: `notionPageId` (nullable until first sync),
  `lastModifiedLocal`, `lastModifiedRemote`, `syncStatus` (synced/pending/conflict).

## Current Status

Project starting fresh. The previous code (`apps/`) used a P2P architecture with
event sourcing and Tailscale that no longer applies.

Next steps:
1. Create Flutter project from scratch at the root
2. Define Task and Subtask models with sync fields
3. Implement local data layer with drift
4. Implement basic NotionClient
5. Sync engine with change queue
6. Minimalist grayscale UI
