# Development Setup

## Prerequisites

- **Go 1.25+**
- **Git**
- **golangci-lint** (required for pre-commit hooks)

## Quick Start

```bash
# 1. Clone
git clone https://github.com/pinchtab/pinchtab.git
cd pinchtab

# 2. Check environment (optional but recommended)
./doctor.sh

# 3. Setup (installs git hooks, downloads deps)
./setup.sh

# 4. Build and run
go build ./cmd/pinchtab
./pinchtab
```

That's it! Git hooks are installed automatically and will run on every commit.

## Detailed Setup

### 1. Clone the repository

```bash
git clone https://github.com/pinchtab/pinchtab.git
cd pinchtab
```

### 2. Run setup script

```bash
./setup.sh
```

This will:
- Install git hooks (gofmt + golangci-lint checks before commit)
- Download Go dependencies
- Verify your environment

### 3. Verify environment (optional)

Check your development environment anytime:

```bash
./doctor.sh
```

This checks:
- ✅ Go version (critical: 1.25+)
- ✅ golangci-lint (critical: required for pre-commit)
- ⚠️  Git hooks installed
- ⚠️  Node.js / Bun (for dashboard development)

### 4. Install golangci-lint (required)

Required for pre-commit hooks:

```bash
# macOS/Linux
brew install golangci-lint

# Or via Go
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

The pre-commit hook will warn and allow commits without it, but CI will fail.

## Before Committing

Git hooks automatically run on `git commit`. To manually check your code:

```bash
# Format code
gofmt -w .

# Run linter
golangci-lint run

# Run tests
go test ./...
```

## Common Issues

### "Git hooks not running on commit"

Re-run setup:
```bash
./scripts/install-hooks.sh
```

Verify hooks installed:
```bash
cat .git/hooks/pre-commit
```

### "golangci-lint: command not found" during commit

Hooks will warn but still allow commit. To fix:
```bash
brew install golangci-lint
# or
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### gofmt fails in CI even though local commit worked

Run format before committing:
```bash
gofmt -w .
```

### Tests failing locally

```bash
# Run full test suite
go test ./...

# Run with verbose output
go test -v ./...

# Run specific test
go test -run TestName ./...
```

## Running Tests

```bash
# All tests
go test ./...

# Verbose output
go test -v ./...

# Specific test
go test -run TestName ./...

# With coverage
go test -cover ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Code Style

- **Format:** `gofmt` (automatic via git hook, or run `gofmt -w .`)
- **Lint:** `golangci-lint` (automatic via git hook, or run `golangci-lint run`)
- **Tests:** Must pass (`go test ./...`)

## Git Workflow

```bash
# 1. Create branch
git checkout -b feature/your-feature

# 2. Make changes
# ... edit files ...

# 3. Test your changes
go test ./...

# 4. Commit (git hooks run automatically: gofmt + lint)
git commit -m "feat: description"

# 5. Push
git push origin feature/your-feature

# 6. Create Pull Request on GitHub
```

**Note:** Git hooks automatically run `gofmt` and `golangci-lint` on staged files before each commit. If checks fail, the commit is blocked.

## Documentation

Update docs when adding features:

```bash
# Docs location
docs/
├── core-concepts.md
├── get-started.md
├── references/
├── architecture/
└── guides/
```

Validate docs: `./scripts/check-docs-json.sh`

## Useful Commands

```bash
# Setup & Verification
./doctor.sh                      # Check development environment
./setup.sh                       # Setup dev environment (run once)
./scripts/install-hooks.sh       # Re-install git hooks

# Build & Run
go build ./cmd/pinchtab          # Build pinchtab binary
go run ./cmd/pinchtab            # Build and run
go clean                         # Clean build cache

# Code Quality
gofmt -w .                       # Format all files
gofmt -l .                       # List files that need formatting
golangci-lint run                # Run linter

# Testing
go test ./...                    # Run all tests
go test -v ./...                 # Verbose output
go test -run TestName ./...      # Specific test
go test -cover ./...             # With coverage

# Dependencies
go mod download                  # Download dependencies
go mod tidy                      # Clean up go.mod
go get -u ./...                  # Update dependencies
```

## Getting Help

- Read the [Overview](docs/overview.md)
- Check [Architecture](docs/architecture/pinchtab-architecture.md)
- See [API Reference](docs/references/instance-api.md)
- Browse [Guides](docs/guides/)
