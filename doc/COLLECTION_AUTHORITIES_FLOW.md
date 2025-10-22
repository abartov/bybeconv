# Collection Authorities Data Flow

## Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Ingestible                                │
│                                                                   │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    │
│  │ collection_authorities  │    │  default_authorities    │    │
│  │                         │    │                         │    │
│  │ - editor (seqno: 1)     │◄───┤ - editor (seqno: 1)    │    │
│  │                         │ M  │ - translator (seqno: 2) │    │
│  └─────────────────────────┘    └─────────────────────────┘    │
│           │                                   │                  │
│           │ Mirrors when                      │                  │
│           │ should_mirror_authorities?        │                  │
│           │ returns true                      │                  │
│           │                                   │                  │
└───────────┼───────────────────────────────────┼──────────────────┘
            │                                   │
            │ During Ingestion                  │ During Ingestion
            │                                   │
            ▼                                   ▼
    ┌──────────────────┐              ┌──────────────────┐
    │   Collection     │              │   Individual      │
    │                  │              │   Texts           │
    │ InvolvedAuthority│              │                   │
    │ - editor         │              │ Work:             │
    │                  │              │  - author (specific)
    │                  │              │                   │
    │                  │              │ Expression:       │
    │                  │              │  - translator (default)
    │                  │              │  - author (propagated)
    └──────────────────┘              │                   │
                                      │ Manifestation     │
                                      └──────────────────┘
```

## Mirroring State Machine

```
┌─────────────────────────────────────────────────────────────┐
│                    Initial State                             │
│                                                               │
│  collection_authorities: []                                   │
│  default_authorities: []                                      │
│                                                               │
│  State: MIRRORING ACTIVE                                      │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    │ User selects volume
                    │ update_authorities_and_metadata_from_volume()
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              After Volume Selection                          │
│                                                               │
│  collection_authorities: [editor]                             │
│  default_authorities: [editor]  ← automatically mirrored      │
│                                                               │
│  State: MIRRORING ACTIVE                                      │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ├─── User adds collection authority ───────┐
                    │    (e.g., illustrator)                    │
                    │                                           │
                    ▼                                           ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│  Collection Authority Added      │   │  User Manually Changes Default  │
│                                  │   │  Authorities                     │
│  collection_authorities:         │   │  (e.g., adds translator)         │
│    [editor, illustrator]         │   │                                  │
│  default_authorities:            │   │  collection_authorities:         │
│    [editor, illustrator]         │   │    [editor]                      │
│      ↑ mirrored                  │   │  default_authorities:            │
│                                  │   │    [editor, translator]          │
│  State: MIRRORING ACTIVE         │   │      ↑ manually changed          │
└──────────────────────────────────┘   │                                  │
                                       │  State: MIRRORING BROKEN         │
                                       └─────────────────┬────────────────┘
                                                         │
                                                         │ User changes
                                                         │ collection authority
                                                         ▼
                                       ┌──────────────────────────────────┐
                                       │  Mirroring Stays Broken          │
                                       │                                  │
                                       │  collection_authorities:         │
                                       │    [editor, illustrator]         │
                                       │  default_authorities:            │
                                       │    [editor, translator]          │
                                       │      ↑ NOT updated               │
                                       │                                  │
                                       │  State: MIRRORING BROKEN         │
                                       └──────────────────────────────────┘
```

## Ingestion Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                      Start Ingestion                              │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│              prep_for_ingestion()                                 │
│                                                                    │
│  • Decode TOC                                                      │
│  • Check collection_authorities for TBD persons                    │
│  • Check default_authorities for TBD persons                       │
│  • For each text:                                                  │
│    - Merge work-specific + default_authorities (per role)          │
│    - Validate required authorities (author, translator if needed)  │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ├─── Errors? ───► Display errors, stop
                         │
                         ├─── TBD authorities? ───► Set status to awaiting_authorities
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│            create_or_load_collection()                            │
│            (if not no_volume)                                     │
│                                                                    │
│  • Load or create Collection                                      │
│  • For each authority in collection_authorities:                  │
│    - Skip if new_person (not yet in database)                     │
│    - Check if authority+role already exists on collection         │
│    - Create InvolvedAuthority if not duplicate                    │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│               Loop: For each text in TOC                          │
│               upload_text(toc_line, index)                        │
│                                                                    │
│  • Merge work-specific + default_authorities (per role)           │
│  • Create Work with authors                                        │
│  • Create Expression with translators and other authorities        │
│  • Create Manifestation with markdown                              │
│  • Add to Collection (if not no_volume)                            │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Ingestion Complete                             │
│                                                                    │
│  Collection has:                                                   │
│    • Collection-level authorities from collection_authorities      │
│    • CollectionItems linking to Manifestations                     │
│                                                                    │
│  Each Work/Expression/Manifestation has:                          │
│    • Authorities from merged (work-specific + defaults) per role   │
│    • NO collection-level authorities                               │
└──────────────────────────────────────────────────────────────────┘
```

## Per-Role Merging Example

```
Given:
  default_authorities: [
    { role: 'author', authority_id: 1, authority_name: 'Author A' },
    { role: 'translator', authority_id: 2, authority_name: 'Translator B' }
  ]

Scenario 1: Work with no specific authorities
  work_authorities: []
  Result: [Author A (author), Translator B (translator)]
  
Scenario 2: Work with specific author
  work_authorities: [
    { role: 'author', authority_id: 3, authority_name: 'Author C' }
  ]
  Result: [Author C (author), Translator B (translator)]
  Note: Author C OVERRIDES Author A for the 'author' role
  
Scenario 3: Work with explicit empty array
  work_authorities: '[]'
  Result: []
  Note: Explicit empty overrides ALL defaults
  
Scenario 4: Work with editor (role not in defaults)
  work_authorities: [
    { role: 'editor', authority_id: 4, authority_name: 'Editor D' }
  ]
  Result: [Author A (author), Translator B (translator), Editor D (editor)]
  Note: Editor added, defaults kept because no override for those roles
```

## UI Component Interaction

```
┌─────────────────────────────────────────────────────────────────┐
│                    Form View                                     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Collection-Level Authorities                           │    │
│  │  [Add/Remove Interface]                                 │    │
│  │  ↓ modifies collection_authorities                      │    │
│  │  ↓ triggers mirroring if should_mirror_authorities?     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Default Authorities for Texts                          │    │
│  │  [Add/Remove Interface]                                 │    │
│  │  ↓ modifies default_authorities                         │    │
│  │  ↓ breaks mirroring permanently                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ↓ Save                                                          │
└───┼──────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TOC View (Tab)                                │
│                                                                   │
│  For each text:                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Work Title                                             │    │
│  │  - Work-specific authority                              │    │
│  │  - Default authority (striped background)              │    │
│  │    ↑ from default_authorities only                      │    │
│  │  [Add] [Clear Defaults]                                 │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ↓ Review                                                        │
└───┼──────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Review Screen                                 │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Collection-Level Authorities                           │    │
│  │  - Editor (will be added)                               │    │
│  │  - Illustrator (will be added)                          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Existing Collection Authorities (if collection exists) │    │
│  │  - Compiler (already exists)                            │    │
│  │  - Editor (NEW - highlighted green)                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Default Authorities for Texts                          │    │
│  │  - Author A                                             │    │
│  │  - Translator B                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Texts to be Ingested                                   │    │
│  │  Work 1: Author C (specific), Translator B (default)    │    │
│  │  Work 2: Author A (default), Translator B (default)     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
│  [Ingest]                                                        │
└──────────────────────────────────────────────────────────────────┘
```

## Database State After Ingestion

```
collections
├── id: 1
├── title: "Test Collection"
└── involved_authorities
    ├── authority_id: 10 (Editor)
    │   role: 'editor'
    │   ↑ from collection_authorities
    └── authority_id: 11 (Illustrator)
        role: 'illustrator'
        ↑ from collection_authorities

collection_items
├── collection_id: 1, item_type: 'Manifestation', item_id: 101
└── collection_id: 1, item_type: 'Manifestation', item_id: 102

manifestations
├── id: 101 (Work 1)
│   └── expression
│       ├── involved_authorities
│       │   └── authority_id: 2 (Translator B) role: 'translator'
│       │       ↑ from default_authorities (merged)
│       └── work
│           └── involved_authorities
│               └── authority_id: 3 (Author C) role: 'author'
│                   ↑ from work-specific authorities
│
└── id: 102 (Work 2)
    └── expression
        ├── involved_authorities
        │   └── authority_id: 2 (Translator B) role: 'translator'
        │       ↑ from default_authorities (merged)
        └── work
            └── involved_authorities
                └── authority_id: 1 (Author A) role: 'author'
                    ↑ from default_authorities (merged)

NOTE: Editor and Illustrator are NOT on the Work/Expression/Manifestations
      They exist ONLY on the Collection
```
