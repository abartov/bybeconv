# Project Ben-Yehuda Copilot Instructions

## Quick Reference

### Essential Commands
```bash
# Run tests
bundle exec rspec

# Run linters on changed files
bundle exec pronto run -c origin/master

# Run RuboCop on a specific file
bundle exec rubocop -a path/to/file.rb

# Start Rails server
bundle exec rails server

# Rails console
bundle exec rails console

# Database setup
bundle exec rails db:create db:migrate

# View all rake tasks
bundle exec rake -T
```

See detailed sections below for more information.

---

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

#### RuboCop (Ruby Style Guide)
```bash
# Check single file
bundle exec rubocop path/to/file.rb

# Check entire project (will show many warnings - legacy code)
bundle exec rubocop

# Auto-correct with safe corrections
bundle exec rubocop -a path/to/file.rb

# Auto-correct with potentially unsafe corrections
bundle exec rubocop -A path/to/file.rb

# Check specific directories
bundle exec rubocop app/models/
bundle exec rubocop spec/
```

#### HAML Lint (HAML Template Linter)
```bash
# Check single file
bundle exec haml-lint path/to/file.haml

# Check all HAML files
bundle exec haml-lint app/views/

# Auto-correct HAML files
bundle exec haml-lint -a path/to/file.haml
```

#### Pronto (Check Only Changed Lines)
Best for checking only the changes you've made:
```bash
# Check changes compared to master branch
bundle exec pronto run -c origin/master

# Check changes with specific formatters (used in CI)
bundle exec pronto run -f github_pr github_status -c origin/master
```

**Recommended Workflow**: 
1. Make your code changes
2. Run RuboCop on modified files: `bundle exec rubocop -a path/to/modified_file.rb`
3. Before committing, run Pronto to check only your changes: `bundle exec pronto run -c origin/master`

## Testing Guidelines

- Use RSpec for all tests
- Test files are organized by type: controllers, models, services, requests, api, mailers, sidekiq
- Use FactoryBot for test data generation
- Maximum example length: 20 lines
- Maximum nested groups: 6
- Up to 20 memoized helpers allowed per spec

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run a specific test file
bundle exec rspec spec/path/to/spec_file.rb

# Run a specific test by line number
bundle exec rspec spec/path/to/spec_file.rb:42

# Run tests with documentation format
bundle exec rspec --format documentation

# Run tests matching a pattern
bundle exec rspec --tag focus  # if you've tagged tests with :focus
```

### Test Database Setup

Before running tests for the first time, ensure the test database is set up:

```bash
# Create and migrate test database
RAILS_ENV=test bundle exec rails db:create
RAILS_ENV=test bundle exec rails db:migrate

# Or use the combined setup command
RAILS_ENV=test bundle exec rails db:setup
```

**Note**: Tests require MySQL and Elasticsearch to be running. In CI, these are provided via GitHub Actions services (see `.github/workflows/rspec.yml`). For local development, use Docker Compose (see `README.docker.md`).

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

### Docker Setup (Recommended)
Development typically uses Docker Compose setup with all required services (MySQL, Elasticsearch, Redis, Memcached):

```bash
# Navigate to docker directory and start services
cd docker/bybe_dev
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

See `README.docker.md` for detailed Docker setup instructions.

### Local Development
- Local development server runs at: `localhost:3000`
- Routes use HTTPS in development: `routes.default_url_options[:protocol] = 'https'`
- Requires MySQL, Elasticsearch, Redis, and Memcached to be running

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

## Building and Running the Application

### Rails Server
```bash
# Start the Rails server (development mode)
bundle exec rails server

# Start with specific port
bundle exec rails server -p 3001

# Start in production mode (not recommended for development)
RAILS_ENV=production bundle exec rails server
```

### Database Commands
```bash
# Create database
bundle exec rails db:create

# Run migrations
bundle exec rails db:migrate

# Rollback last migration
bundle exec rails db:rollback

# Reset database (drop, create, migrate, seed)
bundle exec rails db:reset

# Seed database with initial data
bundle exec rails db:seed

# Check migration status
bundle exec rails db:migrate:status
```

### Rake Tasks
The project has many custom rake tasks in `lib/tasks/`. View all available tasks:
```bash
# List all rake tasks
bundle exec rake -T

# Some useful tasks:
bundle exec rake count:all              # Count various entities
bundle exec rake collections:refresh    # Refresh collections
bundle exec rake whatsnew:since_date    # Show what's new since date
```

### Console Access
```bash
# Rails console for development
bundle exec rails console

# Rails console for specific environment
bundle exec rails console test
bundle exec rails console production
```

### Background Jobs (Sidekiq)
```bash
# Start Sidekiq worker (processes background jobs)
bundle exec sidekiq

# Start Sidekiq with specific configuration
bundle exec sidekiq -C config/sidekiq.yml
```

### Assets
```bash
# Precompile assets (typically for production)
bundle exec rails assets:precompile

# Clean compiled assets
bundle exec rails assets:clean

# Clear all compiled assets
bundle exec rails assets:clobber
```

## When Making Changes

1. Run RuboCop on files you modify: `bundle exec rubocop path/to/file.rb`
2. Use RuboCop auto-correct when appropriate: `bundle exec rubocop -a path/to/file.rb`
3. Write RSpec tests for new functionality
4. Run tests to verify your changes: `bundle exec rspec spec/path/to/related_spec.rb`
5. Consider the impact on Hebrew text rendering and RTL layout
6. Check for N+1 queries when adding database queries
7. Update related tests when modifying existing functionality
8. Use Pronto to check only your changes: `bundle exec pronto run -c origin/master`
