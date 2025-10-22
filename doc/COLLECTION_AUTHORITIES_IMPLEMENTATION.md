# Implementation Notes: Separation of Collection-Level and Default Authorities

## Problem Statement

Previously, `default_authorities` in Ingestibles served two contradictory roles:
1. Default involved authorities for individual texts in the ingestible
2. Involved authorities to be linked to the collection itself during ingestion

This dual role created conflicts when the authorities needed for the collection differed from those needed as defaults for texts.

## Solution Design

### New Field: `collection_authorities`
- Stores authorities that will be linked to the Collection entity
- JSON array format, identical to `default_authorities`
- Separate from text-level defaults

### Mirroring Mechanism
To provide convenience while maintaining separation, we implement "smart mirroring":
- When collection authorities are set and default authorities haven't been manually modified, collection authorities automatically become the defaults
- Once a user manually changes default authorities, mirroring stops permanently
- This allows for the common case (same authorities for both) while supporting divergence when needed

### Implementation Details

#### Mirroring Logic (in Ingestible model)
```ruby
def should_mirror_authorities?
  # Mirror if:
  # 1. default_authorities is blank, OR
  # 2. default_authorities equals the OLD value of collection_authorities
  #    (meaning user hasn't manually changed it since last mirror)
  default_authorities.blank? || default_authorities == collection_authorities_was
end
```

This ensures:
- Initial population from volume → mirrors
- User changes default authorities → stops mirroring
- User changes collection authorities again → still doesn't mirror (respects user's manual changes)

#### During Ingestion

**For Collection (create_or_load_collection method):**
```ruby
if @ingestible.collection_authorities.present?
  JSON.parse(@ingestible.collection_authorities).each do |auth|
    # Only add if:
    # 1. Authority exists in database (authority_id present)
    # 2. This authority+role combo doesn't already exist on collection
    unless @collection.involved_authorities.find_by(authority_id: auth['authority_id'], role: auth['role'])
      @collection.involved_authorities.create!(...)
    end
  end
end
```

**For Individual Texts (upload_text method):**
```ruby
# Uses merge_authorities_per_role with default_authorities
auths = merge_authorities_per_role(toc_line[2], @ingestible.default_authorities)
# Then creates involved authorities on Work, Expression based on these merged authorities
```

Key point: `collection_authorities` is NEVER used here.

#### Per-Role Merging (unchanged from before)
- If a work has specific authority for role X, use it
- If a work doesn't have specific authority for role X, use default for role X
- If work authorities is explicitly `'[]'`, use no authorities at all (overrides all defaults)

### UI Flow

#### Form (`_form.html.haml`)
1. **Collection-level authorities section** (new)
   - Header: "Collection-level Involved Authorities"
   - Help text explaining they link to Collection, with mirroring info
   - Add/remove authorities interface
   
2. **Default authorities section** (modified)
   - Header: "Default Involved Authorities for Texts"
   - Help text explaining they're defaults for individual texts
   - Same add/remove interface as before

#### Review Screen (`review.html.haml`)
1. **Collection authorities display**
   - Shows collection authorities to be added
   
2. **Existing collection authorities** (if collection exists)
   - Lists current authorities on the collection
   - Highlights NEW authorities (green background + badge)
   - Clear visual separation

3. **Default authorities display**
   - Shows text-level defaults separately

#### TOC Screen (`_toc.html.haml`)
- No changes needed
- Already uses only `default_authorities`
- Shows work-specific authorities
- Shows applicable defaults (with striped background)
- Allows clearing defaults per work

### Controllers

#### IngestiblesController
- `prep_for_ingestion`: Checks BOTH collection_authorities and default_authorities for TBD persons
- `create_or_load_collection`: Uses collection_authorities to populate collection
- `upload_text`: Uses default_authorities (via merge_authorities_per_role) for texts

#### IngestibleAuthoritiesController (existing)
- Manages `default_authorities`
- No mirroring logic (doesn't need to know about collection_authorities)
- Manual changes here automatically break mirroring (because they change default_authorities)

#### IngestibleCollectionAuthoritiesController (new)
- Manages `collection_authorities`
- Calls `mirror_collection_to_default_authorities` after each change (if appropriate)
- Identical structure to IngestibleAuthoritiesController

### Testing Strategy

Tests cover:
1. **Model mirroring logic**
   - should_mirror_authorities? returns correct values
   - mirror_collection_to_default_authorities works correctly
   - update_authorities_and_metadata_from_volume populates collection_authorities and mirrors appropriately

2. **Controller ingestion separation**
   - Collection gets authorities from collection_authorities
   - Texts get authorities from default_authorities (merged per role)
   - No duplication of authorities on collection

3. **Collection authorities controller**
   - CRUD operations work correctly
   - Mirroring happens when appropriate
   - Manual changes to defaults stop mirroring

### Edge Cases Handled

1. **Empty collection_authorities**: No collection authorities added during ingestion
2. **Empty default_authorities**: No default authorities used for texts (only work-specific)
3. **Existing collection authorities**: Checks before adding to avoid duplicates
4. **TBD authorities**: Checked in both collection_authorities and default_authorities
5. **Work-specific authority overrides**: Per-role merging still works correctly
6. **Explicit authority clearing**: `'[]'` in TOC still overrides all defaults

### Backward Compatibility

- Existing ingestibles with only `default_authorities` work unchanged
- New field `collection_authorities` starts empty
- No data migration needed
- If collection_authorities is empty, ingestion behaves as before (no collection authorities added)

### Future Considerations

1. **Migration of existing data**: If desired, could create a one-time migration to split existing default_authorities into collection_authorities and default_authorities based on some heuristic

2. **UI indicators**: Could add visual indicator in form when mirroring is active vs broken

3. **Re-enable mirroring**: Could add button to "reset defaults from collection authorities" if user wants to re-enable mirroring

4. **Audit trail**: Could track when mirroring breaks (who changed what when)

## Files Modified

### Models
- `app/models/ingestible.rb`

### Controllers
- `app/controllers/ingestibles_controller.rb`
- `app/controllers/ingestible_collection_authorities_controller.rb` (new)

### Views
- `app/views/ingestibles/_form.html.haml`
- `app/views/ingestibles/_collection_authorities.html.haml` (new)
- `app/views/ingestibles/review.html.haml`
- `app/views/ingestible_collection_authorities/_authority.html.haml` (new)
- `app/views/ingestible_collection_authorities/create.js.erb` (new)
- `app/views/ingestible_collection_authorities/destroy.js.erb` (new)
- `app/views/ingestible_collection_authorities/replace.js.erb` (new)

### Routes
- `config/routes.rb`

### Migrations
- `db/migrate/20251018212238_add_collection_authorities_to_ingestibles.rb` (new)

### Locales
- `config/locales/he.yml`
- `config/locales/en.yml`

### Tests
- `spec/models/ingestible_spec.rb`
- `spec/controllers/ingestibles_controller_spec.rb`
- `spec/controllers/ingestible_collection_authorities_controller_spec.rb` (new)

## Testing Instructions

1. **Create a new ingestible with a volume**
   - Select or create a volume
   - Add collection authorities (e.g., editor)
   - Verify default authorities are automatically populated (mirroring)
   - Save and check database

2. **Manually change default authorities**
   - Add a different authority to defaults (e.g., translator)
   - Change collection authority
   - Verify defaults DON'T change (mirroring broken)

3. **Test ingestion**
   - Complete the ingestible
   - Add some texts with specific authorities
   - Add some texts without specific authorities
   - Review screen should show:
     - Collection authorities clearly
     - If collection exists, existing authorities + new ones highlighted
     - Default authorities separately
   - Ingest
   - Verify:
     - Collection has collection authorities added
     - Texts have merged authorities (work-specific + defaults per role)
     - No collection authority appears on texts unless it's also in defaults

4. **Test with existing collection**
   - Create ingestible for existing collection
   - Add collection authority that already exists
   - Verify no duplication after ingestion

5. **Test TOC functionality**
   - Verify TOC shows only default authorities (not collection)
   - Add specific authority to a work
   - Verify defaults still show for other roles
   - Clear defaults for a work
   - Verify no defaults show for that work

## Troubleshooting

### Mirroring not working
- Check if default_authorities was previously manually changed
- Verify should_mirror_authorities? returns true
- Check logs for any errors during save

### Duplicate authorities on collection
- Verify collection_authorities doesn't include duplicates before ingestion
- Check create_or_load_collection for proper duplicate checking

### Wrong authorities on texts
- Verify merge_authorities_per_role is using default_authorities (not collection_authorities)
- Check per-role merging logic
- Verify work-specific authorities are properly formatted in TOC

### UI not updating
- Check JavaScript console for errors
- Verify AJAX responses are correctly formatted
- Check that both collection and default authority lists have unique IDs
