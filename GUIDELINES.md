# Style Guidelines

## 1. General Principles

* **Clarity and Simplicity:** Write readable, straightforward, and easy-to-understand code.
* **Consistency:** Maintain a uniform style throughout the project.
* **Separation of Concerns:** Each component should have a single reason to change.
* **Technology Agnosticism in the Domain:** Business logic should be independent of specific frameworks or libraries.

## 2. Naming Conventions

* **Unique Identifiers:** Use the **`UniqueId`** Value Object for all entity identifiers.
* **Domain Entities:** Class names should be **singular**, preferably **one word** (e.g., `Task`, `Draft`, `Subtask`).
* **Application Managers:** Classes that orchestrate business logic: **`[Name]Manager`** (e.g., `DraftManager`, `TaskManager`).
* **External Clients:** Classes that communicate with external APIs: **`[Name]Client`** (e.g., `NotionClient`).
* **Repositories:** `[Name]Repository` (e.g., `DraftRepository`). They are **abstract** in the domain, implemented in the data layer.
* **Constants:** Use `camelCase` for standalone constants or `PascalCase` for constant class names with `camelCase` static members.

## 3. Architecture

* **Layers:**
    * **Domain:** Pure business logic, entities, Value Objects, and repository interfaces.
    * **Data:** Concrete implementations: local database (DAOs), remote API clients, sync engine.
    * **UI:** Screens, widgets, and theme.
* **CRUD + Sync Queue:** Local SQLite as immediate data store. Changes are marked as pending and synced with Notion when online.
* **Relationships:** Entities reference each other by **`UniqueId`** or Notion page ID, not by direct containment.

## 4. Coding Practices

* **Dart Fmt:** Use the standard Dart formatter (`dart format`).
* **Naming:**
    * Classes, Enums: `PascalCase`.
    * Methods, Variables: `camelCase`.
* **Immutability:** Prefer immutability for Value Objects and models.
* **No Code Generation:** All code is written manually. No build_runner, no `*.g.dart` files.
* **Dependency Management:** Dependencies are wired manually. No service locators or DI frameworks.
