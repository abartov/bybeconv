# Separation of Collection-Level and Default Authorities

## Overview
This implementation separates the two roles that `default_authorities` previously served:
1. Collection-level involved authorities (linked to the Collection entity)
2. Default authorities for individual texts (used when no specific authorities are defined)

## Database Changes

### Migration
- Added `collection_authorities` text field to `ingestibles` table
- Location: `db/migrate/20251018212238_add_collection_authorities_to_ingestibles.rb`

## Model Changes

### Ingestible Model (`app/models/ingestible.rb`)
- Modified `update_authorities_and_metadata_from_volume` to populate `collection_authorities` instead of `default_authorities`
- Added `should_mirror_authorities?` method - checks if collection authorities should be mirrored to default authorities
- Added `mirror_collection_to_default_authorities` method - copies collection authorities to default authorities
- Mirroring logic:
  - Mirrors when `default_authorities` is blank
  - Mirrors when `default_authorities` equals the previous `collection_authorities` value
  - Does NOT mirror when user has manually changed `default_authorities`

## Controller Changes

### IngestiblesController (`app/controllers/ingestibles_controller.rb`)
- Updated `DEFAULTS` constant to include `collection_authorities`
- Modified `create_or_load_collection` method:
  - Now uses `collection_authorities` to add involved authorities to collections
  - Avoids duplicating authorities already present on the collection
  - Applies to both new and existing collections
- Modified `prep_for_ingestion` method:
  - Checks both `collection_authorities` and `default_authorities` for TBD authorities
  - Uses only `default_authorities` for individual text validation (unchanged)

### IngestibleCollectionAuthoritiesController (NEW)
- Location: `app/controllers/ingestible_collection_authorities_controller.rb`
- Handles CRUD operations for collection-level authorities
- Actions:
  - `create` - adds new collection authority, triggers mirroring if appropriate
  - `destroy` - removes collection authority, triggers mirroring if appropriate
  - `replace` - replaces "new_person" with existing authority
- All actions check and apply mirroring logic automatically

## View Changes

### Form View (`app/views/ingestibles/_form.html.haml`)
- Added new section for collection-level authorities (before default authorities)
- Separated default authorities section with clear labeling
- Both sections use identical UI patterns (autocomplete, role selection, etc.)

### Collection Authorities Partial (NEW)
- Location: `app/views/ingestibles/_collection_authorities.html.haml`
- Displays collection-level authorities list
- Provides interface to add/remove collection authorities
- JavaScript handlers for autocomplete and AJAX operations

### Collection Authority Item Partial (NEW)
- Location: `app/views/ingestible_collection_authorities/_authority.html.haml`
- Displays individual collection authority with delete/replace options
- Uses "coll_ia" prefix to distinguish from default authorities

### Review Screen (`app/views/ingestibles/review.html.haml`)
- Shows collection-level authorities in dedicated section
- Shows existing collection authorities when collection already exists
- Highlights NEW authorities that will be added to collection (green background)
- Shows default authorities for texts in separate section
- Clear visual separation between collection and text authorities

### TOC View (`app/views/ingestibles/_toc.html.haml`)
- No changes needed - already uses only `default_authorities`
- Per-role merging logic correctly ignores `collection_authorities`

## JavaScript Views (NEW)

### Create Response
- Location: `app/views/ingestible_collection_authorities/create.js.erb`
- Appends new authority to collection authorities list
- Updates default authorities list if mirroring occurred

### Destroy Response
- Location: `app/views/ingestible_collection_authorities/destroy.js.erb`
- Removes authority from collection authorities list
- Updates default authorities list if mirroring occurred

### Replace Response
- Location: `app/views/ingestible_collection_authorities/replace.js.erb`
- Refreshes collection authorities list
- Updates default authorities list if mirroring occurred

## Routes
- Added nested resource: `ingestibles/:ingestible_id/collection_authorities`
- Actions: `create`, `destroy`, and member action `replace`

## Translations

### Hebrew (`config/locales/he.yml`)
- `collection_level_authorities` - Collection-level authorities header
- `collection_authorities_help` - Explanation of collection authorities and mirroring
- `default_authorities_for_texts` - Default authorities header
- `default_authorities_help` - Explanation of default authorities
- `existing_collection_authorities` - Header for existing collection authorities
- `no_existing_authorities` - Message when collection has no authorities
- `new_authority` - Badge text for newly added authorities
- `clear_defaults` - Button text to clear default authorities

### English (`config/locales/en.yml`)
- Same keys as Hebrew with English translations

## Testing

### Model Specs (`spec/models/ingestible_spec.rb`)
- Tests for `should_mirror_authorities?` method:
  - Returns true when default_authorities is blank
  - Returns true when default_authorities matches old collection_authorities
  - Returns false when default_authorities was manually changed
- Tests for `mirror_collection_to_default_authorities` method
- Tests for `update_authorities_and_metadata_from_volume` method:
  - Populates collection_authorities from volume
  - Mirrors to default_authorities when appropriate
  - Does not mirror when default_authorities was manually changed

### Controller Specs (`spec/controllers/ingestibles_controller_spec.rb`)
- Tests for `#ingest` action:
  - Uses collection_authorities for collection involved authorities
  - Uses default_authorities (not collection_authorities) for text involved authorities
  - Does not duplicate collection authorities if they already exist

### Collection Authorities Controller Specs (NEW)
- Location: `spec/controllers/ingestible_collection_authorities_controller_spec.rb`
- Tests for `#create`:
  - Adds authority to collection_authorities
  - Mirrors to default_authorities when blank
  - Does not mirror when default_authorities was manually changed
- Tests for `#destroy`:
  - Removes authority from collection_authorities
  - Also removes from default_authorities when mirroring is active
- Tests for `#replace`:
  - Replaces new_person with authority

## Key Behavioral Changes

### Before
1. `default_authorities` served dual purpose (collection + texts)
2. Changing volume would reset authorities for both collection and texts
3. No way to have different authorities for collection vs texts

### After
1. `collection_authorities` - only for Collection entity
2. `default_authorities` - only for individual texts
3. Mirroring provides convenience: when collection authorities are set and defaults haven't been manually changed, collection authorities become defaults
4. Once user manually changes default authorities, mirroring stops
5. Volume changes update collection authorities (and mirror if appropriate)
6. Individual text authorities use per-role merging with default authorities (unchanged)

## Backward Compatibility

- Old ingestibles with only `default_authorities` will continue to work
- New `collection_authorities` field starts empty
- No migration of existing data needed
- If `collection_authorities` is empty, no collection authorities will be added during ingestion
- Default authorities continue to work as text-level defaults regardless of collection_authorities

## Testing Notes

Due to Ruby version mismatch (system has 3.2.3, project requires 3.3.8), automated tests could not be executed. All syntax checks passed:
- Ruby syntax: OK for all .rb files
- HAML structure: Verified manually
- Test structure: Follows existing patterns in the codebase

Manual testing recommended:
1. Create new ingestible with collection and default authorities
2. Verify mirroring behavior when changing collection authorities
3. Manually change default authorities and verify mirroring stops
4. Perform ingestion and verify:
   - Collection authorities are linked to Collection
   - Default authorities are used for texts (per-role merge)
   - New collection authorities are highlighted in review screen
5. Test with existing collections (authorities should not duplicate)
