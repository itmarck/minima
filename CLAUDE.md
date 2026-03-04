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
    platform/      # Platform channels (Android native features)
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
- **Task**: pulled from Notion Tasks database, progress can be updated locally.
  Has a `progress` field (0–100 integer: 0 = pending, 1–99 = in progress,
  100 = done). Completing a task sets progress to `100`.
- **Subtask**: pulled from Notion Subtasks database (separate, related to Task),
  progress can be updated locally. Has a `progress` field (same 0–100 scale).
  Completing a subtask sets progress to `100`.
- **PackagePreference**: local-only (not synced with Notion). Stores per-package
  settings: `isHome` (show on home screen), `isHidden` (hide from app list),
  `homeOrder` (position in home list).

More entities will be added incrementally.

### Display Models

- **TaskItem**: unified display model for tasks and subtasks. Contains `id`,
  `notionPageId`, `title`, `subtitle`, `isSubtask`. Subtitle shows progress
  label (derived from the 0–100 value) for tasks and parent task name for
  subtasks. Created by `TaskManager`.
- **Actionable**: generic result from the input search. Contains `label`, `id`,
  `type` (enum `ActionableType`). Currently only `ActionableType.package`
  exists, extensible for future types.

### Data Flow

The launcher does NOT have full CRUD on all entities. Each entity has a specific
directional flow:

- **Draft** (launcher -> Notion): created locally, pushed to Notion Inbox.
  The launcher only writes drafts; it never receives them back.
- **Task** (Notion <-> launcher): pulled from Notion, cached locally.
  The launcher can only update progress (set to `100` to complete).
  It never creates or deletes tasks.
- **Subtask** (Notion <-> launcher): pulled from Notion, cached locally.
  Same as Task: only completion (progress `100`) allowed from the launcher.
- **PackagePreference** (local only): created and managed entirely in local
  SQLite. No sync with Notion.

There is no delete operation from the launcher. Only progress updates
(completing tasks/subtasks) that get synced back to Notion.

### Offline-First Flow

1. User creates a draft -> immediate write to local SQLite -> instant UI
   feedback.
2. SyncEngine attempts to push pending drafts in background (decoupled from UI).
3. User completes a task/subtask -> progress update (100) saved locally with
   timestamp -> item removed from UI immediately (optimistic update).
4. On connection detected: push pending drafts to Notion Inbox, push pending
   progress updates (tasks and subtasks) to Notion, pull latest tasks/subtasks
   from Notion.
5. Notion is the source of truth; SQLite is cache + offline store.

Creation and sync are decoupled: the user never waits for Notion. The experience
is identical online and offline.

### Draft creation flow:
```
Input -> DraftManager.create() -> SQLite (instant) -> UI clear
                                                      |
                                    SyncEngine.syncPendingDrafts()
                                                      |
                              NotionClient.createInboxEntry() (background)
                                                      |
                                  DraftRepository.updateSyncStatus()
```

### Task completion flow:
```
Checkbox tap -> setState (optimistic remove) -> TaskManager.markComplete()
                                                      |
                                         SQLite (progress = 100/pending sync)
                                                      |
                                              SyncEngine.sync()
                                                      |
                              NotionClient.updateTaskProgress() or
                              NotionClient.updateSubtaskProgress() (background)
```

### Sync Trigger

- On app start: attempt full sync immediately.
- On connectivity change: sync when device goes online.
- On draft creation: trigger push-only sync (`syncPendingDrafts`).
- On task/subtask completion: trigger full sync (`sync`).

### Sync Cycle (full)

```
SyncEngine.sync():
  1. Push pending drafts   -> NotionClient.createInboxEntry()
  2. Push pending tasks    -> NotionClient.updateTaskProgress(pageId, 100)
  3. Push pending subtasks -> NotionClient.updateSubtaskProgress(pageId, 100)
  4. Pull tasks            -> NotionClient.fetchTasks()
  5. Pull subtasks         -> NotionClient.fetchSubtasks()
  6. Callback              -> onSyncComplete()
```

### Notion Database Auto-Discovery

Database IDs are not manually configured. The SyncEngine auto-discovers them:

1. On first sync, calls `NotionClient.searchDatabases(token)` which uses
   `POST /v1/search` with `{filter: {value: "database", property: "object"}}`.
2. Matches database titles case-insensitively: `Inbox`, `Tasks`, `Subtasks`.
3. Caches discovered IDs in `flutter_secure_storage` for subsequent launches.
4. Only the Notion integration token is required from the user.

### Platform Features

Some features are platform-specific and only available on Android:

- **Package listing**: Uses a MethodChannel (`com.itmarck.minima/packages`) to
  query installed packages and launch them. On Windows, the channel returns empty
  results and the UI gracefully hides package-related features.
- **PackageInfo**: A read-only data class (not a synced entity). It has no
  UniqueId and no sync fields. Represents an installed package (packageName,
  label, icon bytes).
- **PackageManager**: Caches the full package list in memory after initial load.
  Provides search filtering without additional platform channel calls. Extended
  with `PackagePreferenceRepository` for home/hidden app management.

Windows is not a launcher -- it is a standalone app. It does not list or launch
system packages.

### Database Schema (v4)

- **drafts**: id, title, created_at, notion_page_id, last_modified_local,
  last_modified_remote, sync_status
- **tasks**: id, title, notion_page_id, last_modified_local,
  last_modified_remote, sync_status, progress
- **subtasks**: id, title, task_id, notion_page_id, last_modified_local,
  last_modified_remote, sync_status, progress
- **package_preferences**: package_name (PK), is_home, is_hidden, home_order

Migrations:
- v1 -> v2: `ALTER TABLE tasks ADD COLUMN status`
- v2 -> v3: `CREATE TABLE package_preferences`
- v3 -> v4: `ALTER TABLE tasks ADD COLUMN progress` + `ALTER TABLE subtasks ADD COLUMN progress`

### Configuration

Notion integration token is stored in encrypted storage
(`flutter_secure_storage`). Database IDs are auto-discovered and cached.
Launcher preferences (home apps alignment) are also stored in secure storage.

Storage keys (defined in `SettingsScreen`):
- `notion_api_token`: Notion integration token (user-configured)
- `notion_inbox_database_id`: cached Inbox DB ID (auto-discovered)
- `notion_tasks_database_id`: cached Tasks DB ID (auto-discovered)
- `notion_subtasks_database_id`: cached Subtasks DB ID (auto-discovered)
- `home_apps_alignment`: `left` or `right` (user-configured, default `left`)

## UI Architecture

### Screens

- **HomeScreen**: main launcher surface. Top bar with pending count and settings
  icon. Empty center area (long-press opens app list). Bottom section with
  favorite apps, actionable results, text input, and drafts link. Swipe up on
  input area opens task bottom sheet.
- **PackageListScreen**: full app list. Visible apps at top, hidden apps in
  expandable accordion at bottom. Long-press on any app shows context menu
  (Add/Remove from home, Hide/Show).
- **SettingsScreen**: Notion token configuration, launcher preferences
  (home apps alignment toggle), and storage actions (clear cache: Notion DB
  IDs, clear local data: drafts/tasks/subtasks).

### Widgets

- **FavoriteApps**: vertical list of up to 5 home-screen apps. Fixed height
  (5 slots always reserved). Configurable horizontal alignment (left/right).
- **ActionableResults**: search results from the input field. Fixed height
  (3 slots always reserved). Two-row tiles (title + type subtitle). Appears
  between favorite apps and input.
- **TaskList**: list of task/subtask items with checkboxes. Two-row layout
  (title + metadata subtitle). Used inside TaskBottomSheet.
- **TaskBottomSheet**: modal bottom sheet (70% screen height) triggered by
  swipe up. Contains TaskList with drag handle.
- **DigitalClock**: HH:MM display (currently unused, available for future use).

### Home Screen Layout

```
SafeArea -> Column
  +-- Top bar (pending count | settings icon)
  +-- Expanded (empty, long-press -> app list)
  +-- Bottom section (swipe-up -> task sheet)
       +-- FavoriteApps (fixed 5-slot height)
       +-- ActionableResults (fixed 3-slot height)
       +-- TextField (draft input + package search)
       +-- "Show drafts" link
```

The bottom section uses fixed-height widgets so that elements maintain stable
positions regardless of content changes (e.g. actionables appearing/disappearing
do not shift favorite apps).

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
- Display models: TaskItem, Actionable
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

### UI

- Visual design defined in `DESIGN.md`
- Fixed-height containers for dynamic content to prevent layout shifts
- Optimistic UI updates for user actions (remove item immediately, sync later)
- Widgets receive data and callbacks; they do not access repositories directly

## Current Status

Flutter project with full offline-first architecture. SQLite local storage
(v3), Notion bidirectional sync with auto-discovery, and grayscale UI.

Implemented:
- Domain: Draft, Task (with progress), Subtask (with progress) models with sync fields
- Domain: PackageInfo, PackagePreference, PackageManager (with preferences)
- Domain: TaskManager with TaskItem display model, pending count
- Domain: Actionable system with ActionableType enum
- Data: sqflite database (v4), DAOs (Draft, Task, Subtask, PackagePreference)
- Data: NotionClient (Inbox push, Tasks/Subtasks pull, progress update,
  database auto-discovery via Search API)
- Data: SyncEngine (full cycle: push drafts + push completions + pull)
- Data: PlatformPackageRepository (MethodChannel to Android)
- Platform: PackageListPlugin (Kotlin) for listing and launching packages
- UI: Home screen (pending count, favorite apps, actionable search, draft
  input, swipe-up task sheet, long-press app list)
- UI: Package list screen (long-press context menu, home/hidden management,
  hidden apps accordion)
- UI: Settings screen (Notion token, home apps alignment)
- UI: Reusable widgets (FavoriteApps, ActionableResults, TaskList,
  TaskBottomSheet, DigitalClock)
- Theme: Grayscale palette (MinimaColors + MinimaTheme)
- Config: Encrypted storage for token and cached DB IDs
