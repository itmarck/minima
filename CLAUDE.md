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

- **Local SQLite** (sqflite) as the primary and immediate data store.
- **Sync queue**: each local change is marked as pending (`dirty flag`).
- **Bidirectional sync with Notion**: on reconnect, push local changes and pull
  remote changes.
- **Conflict resolution**: last-write-wins (personal tool, single user).

### Structure: Single Flutter Monorepo

```
lib/
  domain/          # Entities, value objects, repository interfaces
  data/            # Implementations: SQLite (sqflite), Notion API, sync engine
    local/         # SQLite database, DAOs
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

- **Draft**: quick capture created locally, pushed to Notion Inbox database.
- **Task**: pulled from Notion Tasks database, status can be changed locally.
- **Subtask**: pulled from Notion Subtasks database (separate, related to Task),
  status can be changed locally.

More entities will be added incrementally.

### Data Flow

The launcher does NOT have full CRUD on all entities. Each entity has a specific
directional flow:

- **Draft** (launcher → Notion): created locally, pushed to Notion Inbox.
  The launcher only writes drafts; it never receives them back.
- **Task** (Notion → launcher): pulled from Notion, cached locally.
  The launcher can only update status (e.g. mark as completed).
  It never creates or deletes tasks.
- **Subtask** (Notion → launcher): pulled from Notion, cached locally.
  Same as Task: only status changes allowed from the launcher.

There is no delete operation from the launcher. Only status changes
(completing tasks/subtasks) that get synced back to Notion.

### Offline-First Flow

1. User creates a draft → immediate write to local SQLite → instant UI feedback.
2. SyncEngine attempts to push pending drafts in background (decoupled from UI).
3. User completes a task/subtask → status change saved locally with timestamp.
4. On connection detected: push pending drafts to Notion Inbox, push pending
   status changes to Notion, pull latest tasks/subtasks from Notion.
5. Notion is the source of truth; SQLite is cache + offline store.

Creation and sync are decoupled: the user never waits for Notion. The experience
is identical online and offline.

### Draft creation flow:
```
Input → DraftManager.create() → SQLite (instant) → UI limpia
                                                   ↓
                                    SyncEngine.syncPendingDrafts()
                                                   ↓
                              NotionClient.createInboxEntry() (background)
                                                   ↓
                                  DraftRepository.updateSyncStatus()
```

### Sync Trigger

- On app start: attempt to sync immediately.
- On connectivity change: sync when device goes online.
- On draft creation: trigger background sync.

### Configuration

Notion integration token and Inbox database ID are stored in encrypted storage
(flutter_secure_storage). If no token is configured, everything stays local.

## Guidelines

### General Principles

- Clarity and simplicity: readable, straightforward code.
- Consistency: uniform style throughout the project.
- Separation of concerns: each component has a single reason to change.
- Technology agnosticism in the domain: business logic independent of frameworks.

### Naming

- `UniqueId` Value Object for all entity identifiers
- `[Name]Manager` for business orchestrators (e.g. `DraftManager`, `TaskManager`)
- `[Name]Repository` for data access (abstract in domain, implemented in data)
- `[Name]Client` for external API clients (e.g. `NotionClient`)
- `SyncEngine` for the synchronization engine
- Entities: singular, one word (Task, Draft, Subtask)
- Value Objects: UniqueId, SyncStatus
- Classes, Enums: `PascalCase`
- Methods, Variables: `camelCase`
- Entities reference each other by `UniqueId` or Notion page ID, not by
  direct containment

### Code

- `dart format` as the formatter
- Immutability for value objects and models
- No code generation: all code is written manually (no build_runner, no *.g.dart)
- Manual dependency wiring (no service locator)
- Tests for domain and data layers at minimum
- Do not add features, refactors, or improvements beyond what is requested
- Do not over-engineer: the simplest solution that works

### Sync

- The Notion API has rate limits (~3 requests/second). The sync engine must
  respect this with batching and backoff.
- Each local record has: `notionPageId` (nullable until first sync),
  `lastModifiedLocal`, `lastModifiedRemote`, `syncStatus` (synced/pending).

## Current Status

Flutter project created from scratch. Local data layer (sqflite, raw SQL)
implemented with Draft, Task, and Subtask tables. Domain models, repository
interfaces, and DAOs in place. Basic grayscale home screen with draft input.
Android configured as launcher. Windows platform included.

Implemented:
- Domain: Draft, Task, Subtask models with sync fields
- Data: sqflite database, DAOs, NotionClient (Inbox push), SyncEngine
- UI: Home screen (digital clock, bottom input with send button, settings icon),
  settings screen (Notion token + database ID), drafts modal
- Theme: Grayscale (themed Material widgets)

Next steps:
1. NotionClient: Tasks/Subtasks pull from Notion
2. Task/Subtask display in the launcher UI
3. Refine UI design and architecture
