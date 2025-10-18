# Copyright Expiration Task

This document describes the `copyright_expiration` rake task which automatically transitions authorities and their manifestations to public domain based on copyright expiration rules.

## Overview

In Israel, copyright expires 71 years after the death of the author. This task automates the process of updating the intellectual property status of authorities (authors, translators, etc.) and their associated works when this threshold is reached.

## How It Works

The task performs the following actions:

1. **Identifies authorities**: Finds all people who died exactly 71 years ago (e.g., in 2025, it looks for people who died in 1954)

2. **Updates authorities**: Changes their `intellectual_property` status from any other value to `public_domain`

3. **Updates manifestations**: For each manifestation (work) associated with the updated authority:
   - Checks if ALL involved authorities (authors, translators, etc.) are now `public_domain`
   - If so, updates the expression's `intellectual_property` status to `public_domain`

## Usage

### Dry-Run Mode (Default)

To see what would be updated without making any changes:

```bash
rake copyright_expiration
```

This will:
- Show which authorities would be updated
- Show which manifestations would be updated
- Display statistics
- Make NO actual changes to the database

### Execute Mode

To actually update the database:

```bash
rake copyright_expiration[execute]
```

**Important**: Only use this mode when you're ready to commit the changes to the database.

## Output

The task provides detailed output including:

- Each authority being processed with their current status
- Each manifestation being checked and potentially updated
- Summary statistics:
  - Number of authorities checked
  - Number of authorities updated
  - Number of manifestations checked
  - Number of manifestations updated

### Example Output

```
Running in DRY-RUN mode - no changes will be saved
To execute changes, run: rake copyright_expiration[execute]

Processing authorities who died in 1954 (2025 - 71 years)...

Authority 'שלמה זלמן שניאור' (ID: 123) - died in 1954
  Current status: copyrighted
  Updating to: public_domain
  [DRY-RUN] Would update
  Manifestation 'שירי לב' (ID: 456)
    Expression (ID: 789) current status: copyrighted
    Updating expression to: public_domain
    [DRY-RUN] Would update

================================================================================
SUMMARY
================================================================================
Mode: DRY-RUN
Target year: 1954

Authorities:
  Checked: 5
  Would update: 3

Manifestations:
  Checked: 15
  Would update: 8
================================================================================

This was a dry-run. To apply changes, run:
  rake copyright_expiration[execute]
```

## Multi-Author Works

The task correctly handles works with multiple authors:

- If a work has multiple authors/translators, it will only be updated to `public_domain` if ALL of them are `public_domain`
- This ensures that copyrighted works with living or recently deceased co-authors remain protected

## Scheduling

This task should be run annually, typically at the beginning of each year, to process authorities who died 71 years ago.

You can schedule it using cron or any other task scheduler:

```bash
# Example cron entry to run on January 1st at 2 AM
0 2 1 1 * cd /path/to/bybeconv && rake copyright_expiration[execute]
```

## Safety Features

1. **Dry-run by default**: The default mode makes no changes, reducing the risk of accidental updates
2. **Explicit execute flag**: Must pass `execute` parameter to make actual changes
3. **Skip already public domain**: Authorities already marked as `public_domain` are skipped
4. **Published works only**: Only published manifestations are considered for updates
5. **Comprehensive logging**: All actions are logged to stdout for review

## Technical Details

- The task uses the `death_year` method from the `LifePeriod` concern
- Death year is extracted from the person's `deathdate` field using the `ExtractYear` service
- Intellectual property status is stored at the Authority and Expression levels
- The task uses `find_each` to process records in batches for memory efficiency

## Troubleshooting

### No authorities found

If the task reports 0 authorities checked:
- Verify that there are people with `deathdate` values in the target year
- Check that they have associated authority records
- Ensure the death dates are properly formatted (YYYY or YYYY-MM-DD)

### Manifestations not updating

If authorities are updated but manifestations are not:
- Check that the manifestations are published (`status: :published`)
- Verify that ALL involved authorities are now `public_domain`
- Check the expression's current `intellectual_property` status

## Related Code

- [Authority Model](../../app/models/authority.rb)
- [Person Model](../../app/models/person.rb)
- [Expression Model](../../app/models/expression.rb)
- [LifePeriod Concern](../../app/models/concerns/life_period.rb)
