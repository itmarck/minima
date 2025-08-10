# Architecture Overview

This document outlines an architecture that clearly distinguishes core domain logic from infrastructure mechanisms. The core layer defines the essential building blocks of the domain, while the infrastructure layer is responsible for tracking, persisting, and reconstructing changes to entities. This separation enhances maintainability, auditability, and flexibility, providing a solid foundation for scalable and adaptable application development.

## Core Concepts

### Entities
- **Entity**: The base class for all domain objects, identified by a `UniqueId`, with a creation timestamp and a list of `Reference` objects.

### Reference
- **Reference**: Lightweight value object pointing to another entity, containing its `id`, `kind` (e.g., note, project), and an optional description.

### UniqueId
- **UniqueId**: Strongly-typed UUID wrapper, ensuring global uniqueness for all entities.

## Infrastructure Concepts (Flutter Implementation)

### Events
- **Event**: Infrastructure-level record of a domain change, containing a unique id, entity id, timestamp, and a payload. Events are not part of the domain model but are used for tracking changes in persistence.

### Records
- **Record**: Infrastructure-level representation of a single property change for an entity, linked to an event. Each record stores the entity kind, id, key, value, and creation timestamp.

## Data Flow and Persistence

### Change Tracking Pattern
- The system uses a change-tracking approach: all modifications to entities are captured as events and property records, which are persisted for audit and reconstruction purposes.
- Each event is stored in the `events` table, and its associated property changes are stored as individual `records` in the `records` table.

### Repository Implementation

#### Saving an Entity
- When saving a `Note` or `Project`:
  1. A new event is created and inserted into the `events` table.
  2. For each property (e.g., `content`, `title`, `createdAt`), a new record is inserted into the `records` table, referencing the event.
  3. All records include the entity kind, id, key, value, and timestamp.

#### Loading an Entity
- To reconstruct an entity:
  1. The repository queries the `records` table for all records matching the entity kind and id, ordered by creation time (descending).
  2. The latest value for each property is selected to build the current state of the entity.

#### Searching
- Search operations use SQL window functions to efficiently retrieve the latest value of a property (e.g., `content` or `title`) for each entity.

### Reference Resolution
- The `ReferenceService` extracts references from text (pattern: `{{uuid}}`) and resolves them to typed `Reference` objects by consulting the appropriate repositories.

## Summary Table

| Layer          | Concept         | Description                                                                 |
|--------------- | --------------- | --------------------------------------------------------------------------- |
| Core           | Entity          | Base class for all domain objects, with id, timestamp, and references.      |
| Core           | Reference       | Lightweight pointer to another entity, with kind and description.           |
| Core           | UniqueId        | Strongly-typed UUID for all entities.                                       |
| Application    | Managers        | Orchestrate business logic using domain interfaces.                         |
| Application    | Extraction      | Finds and resolves references in text to entity pointers.                   |
| Infrastructure | Event Table     | Stores all events with metadata for change tracking.                        |
| Infrastructure | Record Table    | Stores property-level changes, linked to events and entities.               |

## Design Highlights

- **Change Tracking**: All state changes are tracked at the infrastructure level, enabling auditability and reconstruction of entity state.
- **Property-level Records**: Fine-grained tracking of changes, supporting partial updates and efficient queries.
- **Reference System**: Decoupled, type-safe references between entities, supporting rich linking and navigation.
- **Extensibility**: New entity types and tracked properties can be added with minimal changes to the core and infrastructure.


This documentation summarizes the architecture, focusing on the separation between core domain concepts and infrastructure-level change tracking, as implemented in the current proof of concept.