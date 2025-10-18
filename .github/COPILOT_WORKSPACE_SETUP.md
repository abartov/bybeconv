# GitHub Copilot Workspace Setup Guide

This document provides setup instructions for GitHub Copilot Agent/Workspace environments to ensure proper functionality when running tests and code.

## Ruby Version

This project requires **Ruby 3.3.9** (as specified in `.ruby-version` and `Gemfile`).

The Copilot Agent environment typically has Ruby 3.2.3 by default, but Ruby 3.3.9 is available at `/opt/hostedtoolcache/Ruby/3.3.9/x64/bin/`.

## Quick Setup

To set up the environment for running tests and code:

```bash
# Add Ruby 3.3.9 to PATH
export PATH="/opt/hostedtoolcache/Ruby/3.3.9/x64/bin:$PATH"

# Verify Ruby version
ruby --version  # Should show ruby 3.3.9

# Install Bundler if not already installed
gem install bundler

# Install system dependencies (required for gems)
sudo apt-get update
sudo apt-get install -y \
  mysql-client \
  libmysqlclient-dev \
  wkhtmltopdf \
  pandoc \
  yaz \
  libyaz-dev \
  libmagickwand-dev \
  libpcap-dev \
  cmake

# Install Ruby dependencies
bundle install

# Verify setup
bundle exec ruby --version
```

## Running Tests

After setup, you can run tests with:

```bash
# Ensure Ruby 3.3.9 is in PATH
export PATH="/opt/hostedtoolcache/Ruby/3.3.9/x64/bin:$PATH"

# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/spec_file.rb
```

## Running Linters

```bash
# Run RuboCop on a single file
bundle exec rubocop path/to/file.rb

# Run RuboCop with auto-correct
bundle exec rubocop -a path/to/file.rb

# Run Pronto (checks only changed files)
bundle exec pronto run -c origin/master
```

## Troubleshooting

### Wrong Ruby Version

If you see errors like "Your Ruby version is X.X.X, but your Gemfile specified 3.3.9":
- Make sure Ruby 3.3.9 is in your PATH: `export PATH="/opt/hostedtoolcache/Ruby/3.3.9/x64/bin:$PATH"`
- Verify with: `ruby --version`

### Bundle Install Fails

If `bundle install` fails:
1. Ensure all system dependencies are installed (see Quick Setup section)
2. Check that you have the correct Ruby version active
3. Try removing `Gemfile.lock` and running `bundle install` again (not recommended for production)

### Tests Fail to Connect to Services

The Copilot Agent environment doesn't include MySQL, Elasticsearch, etc. by default. Tests that require these services will fail unless:
- You're running tests in a GitHub Actions workflow (which has these services configured)
- You set up Docker containers locally (see `README.docker.md`)

## Version Management

This project uses:
- **Ruby**: 3.3.9 (specified in `.ruby-version`, `Gemfile`, and `.tool-versions`)
- **Rails**: 8.0.2.1
- **Bundler**: 2.5.23 (from Gemfile.lock)

## Additional Resources

- Main README: `README.md`
- Docker setup: `README.docker.md`
- GitHub Actions workflows: `.github/workflows/`
