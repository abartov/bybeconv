# Project Ben-Yehuda Copilot Instructions

## About This Project

This codebase runs https://benyehuda.org -- the Project Ben-Yehuda digital library of works in Hebrew. The project focuses on preserving and making accessible Hebrew literature, with special handling for right-to-left text and Hebrew-specific features.

## Technology Stack

- **Ruby Version**: 3.3.8
- **Rails Version**: 8.0.2.1
- **Database**: MySQL (mysql2 gem)
- **Testing Framework**: RSpec with FactoryBot
- **Search**: ElasticSearch 7.x with Chewy gem and Hebrew analyzer
- **Background Jobs**: Sidekiq with Redis backend
- **Caching**: Memcached
- **File Storage**: AWS S3 with Active Storage
- **PDF Generation**: wkhtmltopdf
- **Document Conversion**: Pandoc 3.x

## Code Style and Linting

### RuboCop Configuration
- Maximum line length: 120 characters
- Maximum method length: 100 lines
- Maximum class length: 1500 lines
- Target Ruby version: 3.3.8
- Use rubocop-rails, rubocop-rspec, and rubocop-factory_bot plugins

### Important Style Notes
- Use hash syntax: `{ key: value }` (EnforcedShorthandSyntax is set to 'never')
  - Always write `{ key: value }`, never `{ key }` (hash value omission)
  - Symbol-to-proc like `.map(&:method)` is fine and widely used in the codebase
- Many legacy parts of the codebase do not follow style guidelines - focus on maintaining consistency within the file you're editing
- String concatenation is allowed (Style/StringConcatenation disabled) - this is important for right-to-left texts
- `html_safe` usage is common and accepted in this codebase for rendering Hebrew text

### HAML Linting
- Maximum line length: 120 characters
- Instance variables in views are acceptable
- Inline styles are acceptable
- RuboCop integration enabled (except Layout/SpaceInsideParens)

### Running Linters
```bash
# Check single file with RuboCop
rubocop <path_to_file>

# Auto-correct with safe corrections
rubocop -a <path_to_file>

# Check changes only (via Pronto)
pronto run -c origin/master
```

## Testing Guidelines

- Use RSpec for all tests
- Test files are organized by type: controllers, models, services, requests, api, mailers, sidekiq
- Use FactoryBot for test data generation
- Maximum example length: 20 lines
- Maximum nested groups: 6
- Up to 20 memoized helpers allowed per spec

## Common Patterns and Best Practices

### Hebrew Text Handling
- Always consider right-to-left (RTL) text direction
- When using RMagick for image generation (e.g., book covers), Hebrew text needs `.reverse.center()` to display correctly
- Do NOT use `.reverse` for HTML/web rendering - it will break Hebrew text display
- Be cautious with string operations that might break Hebrew characters or encoding
- The `html_safe` method is frequently used for rendering Hebrew content

### Database and Performance
- Watch for N+1 query problems - use eager loading with `includes` when fetching associated records
- Consider caching for frequently accessed data
- Use `Chewy.strategy(:atomic)` when updating Elasticsearch indexes

### Controllers
- Use `before_action` for authorization checks
- Common authorization methods: `require_editor`, `require_admin`, `require_user`
- Flash messages use I18n: `flash[:notice] = t(:updated_successfully)`

### Models and Associations
- Property sets are used for key/value properties via the property_sets gem
- ElasticSearch indexing is handled through Chewy
- Many models have complex relationships - check existing associations before adding new ones

### Background Jobs
- Use Sidekiq for scheduled and asynchronous tasks
- Job classes should be placed in `app/jobs/` or `app/sidekiq/`

### File Processing
- Pandoc is used for document conversion to Markdown and ebook formats
- Handle DOCX files carefully - Pandoc 3.x is required to avoid SmartTag issues
- ebook generation uses EPUB format with RMagick for cover images

## TOC (Table of Contents) Format

When working with author TOCs (Table of Contents), use this Markdown format:
```
&&& פריט: מ{manifestation_id} &&& כותרת: {title} &&&
```

Or for HtmlFile:
```
&&& פריט: ה{htmlfile_id} &&& כותרת: {title} &&&
```

Section titles like "שירה" (poetry), "פרוזה" (prose), "מאמרים ומסות" (articles and essays) should be formatted as `## {title}`.

## Development Environment

- Development uses Docker Compose setup
- Local development server: `localhost:3000`
- Routes use HTTPS in development: `routes.default_url_options[:protocol] = 'https'`

## Important Notes

- This codebase prioritizes functionality for Hebrew literature over code generalization
- Many parts of the codebase are legacy code that doesn't follow modern Rails conventions
- When modifying code, maintain consistency with the existing file's style
- Always test with right-to-left text and Hebrew characters when making UI changes
- Be mindful of encoding issues when working with files (UTF-8 is standard)

## External Dependencies

- ElasticSearch with Hebrew analyzer: https://github.com/synhershko/elasticsearch-analysis-hebrew
- YAZ and libyaz-dev for the 'zoom' gem (bibliographic workshop)
- Watir and Selenium for scraping catalog systems
- libpcap-dev for net-dns2
- libmagickwand-dev for RMagick
- libmysqlclient-dev for mysql2

## When Making Changes

1. Run RuboCop on files you modify: `rubocop <path_to_file>`
2. Use RuboCop auto-correct when appropriate: `rubocop -a <path_to_file>`
3. Write RSpec tests for new functionality
4. Consider the impact on Hebrew text rendering and RTL layout
5. Check for N+1 queries when adding database queries
6. Update related tests when modifying existing functionality
7. Use Pronto to check only your changes: `pronto run -c origin/master`
