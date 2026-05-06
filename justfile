# MoonBit Project Commands

# Default target (js for browser compatibility)
target := "all"

# Default task: check and test
default: check test

# Format code
fmt:
    moon fmt

# Type check
check:
    moon check --deny-warn --target {{target}}

# Run tests
test:
    moon test --target {{target}}

# Update snapshot tests
test-update:
    moon test --update --target {{target}}

# Run main
run:
    moon run src/main --target {{target}}

# Generate type definition files
info:
    moon info

# Clean build artifacts
clean:
    moon clean

# Pre-release check
release-check: fmt info check test

# Regenerate embedded fixtures from fixtures/ directory
regen-fixtures:
    python3 scripts/embed_fixtures.py . src/parser/fixtures_embedded.mbt
    moon fmt src/parser/fixtures_embedded.mbt

# Check that embedded fixtures are up-to-date (for CI)
fixtures-check:
    python3 scripts/embed_fixtures.py . src/parser/fixtures_embedded.mbt
    moon fmt src/parser/fixtures_embedded.mbt
    @git diff --exit-code src/parser/fixtures_embedded.mbt || (echo "fixtures_embedded.mbt is out of date; run 'just regen-fixtures'" && exit 1)
