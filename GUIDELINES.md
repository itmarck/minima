# Style Guidelines

## 1. General Principles

* **Clarity and Simplicity:** Write readable, straightforward, and easy-to-understand code.
* **Consistency:** Maintain a uniform style throughout the project.
* **Separation of Concerns:** Each component should have a single reason to change.
* **Technology Agnosticism in the Domain:** Business logic should be independent of specific frameworks or libraries.

## 2. Naming Conventions

* **Unique Identifiers:** Use the **`UniqueId`** Value Object for all entity and aggregate identifiers.
* **Domain Entities:** Class names should be **singular**, preferably **one word** (e.g., `Task`, `Note`, `Account`).
* **Application Managers:** Classes that orchestrate business logic will be named **`[Name]Manager`** (e.g., `TaskManager`, `JournalManager`, `ReferenceResolver`).
* **External Services:** Abstract classes representing interfaces to external elements will be named **`[Name]Service`** (e.g., `NetworkService`).
* **Templates:** `TransactionTemplate`, `FinancialTemplate`.
* **References:** `Reference` (Value Object).
* **Events:** The base class for all events is **`Event`**.
* **Repositories:** `[Name]Repository` (e.g., `TaskRepository`). They are **abstract** in the domain, implemented in infrastructure.
* **Constants:** Use `camelCase` for standalone constants or `PascalCase` for constant class names with `camelCase` static members.

## 3. Architecture

* **Layers:** This could be applied by slices in the future.
    * **Domain:** Pure business logic, entities, aggregates, Value Objects, events, and repository/service interfaces.
    * **Application:** **`Managers`** that orchestrate business operations using domain interfaces.
    * **Infrastructure:** Concrete implementations of domain interfaces.
    * **Presentation:** UI (Flutter) and local API.
* **Event Sourcing:** The **immutable sequence of `Event`s** is the single source of truth for an aggregate's state.
    * Events are **immutable** and contain the state at the time they occurred.
* **Aggregates:** Each aggregate has a root and manages its own internal consistency. Relationships between aggregates are by **referencing `UniqueId`s**, not by direct containment.

## 4. Coding Practices

* **Dart Fmt:** Use the standard Dart formatter (`dart format`).
* **Naming:**
    * Classes, Enums: `PascalCase`.
    * Methods, Variables: `camelCase`.
* **Immutability:** Prefer immutability for `Value Objects` and `Event`s.
* **Dependency Management:** Dependencies will be managed manually for initial development.
