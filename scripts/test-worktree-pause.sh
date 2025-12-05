#!/usr/bin/env bash
set -euo pipefail

# test-worktree-pause.sh - Test worktree-pause.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/worktree-pause.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass_count=0
fail_count=0

echo "Testing worktree-pause.sh..."
echo ""

# Test 1: Script exists and is executable
if [[ -x "$SCRIPT" ]]; then
    echo -e "${GREEN}✓${NC} Script is executable"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Script is not executable"
    fail_count=$((fail_count + 1))
    exit 1
fi

# Create temporary worktree structure for tests 2 and 3
TEST_DIR=$(mktemp -d)
echo "gitdir: /tmp/fake/.git/worktrees/test" > "$TEST_DIR/.git"

# Test 2: Validates invalid JSON input (from within mock worktree)
output=$(cd "$TEST_DIR" && echo "invalid json" | "$SCRIPT" 2>&1) || true
if echo "$output" | grep -q "Invalid JSON"; then
    echo -e "${GREEN}✓${NC} Validates JSON input"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should validate JSON input"
    echo "$output"
    fail_count=$((fail_count + 1))
fi

# Test 3: Successfully pauses with valid JSON (from within mock worktree)
output=$(cd "$TEST_DIR" && echo '{"ticket":"TEST-123","summary":"test session"}' | "$SCRIPT" 2>&1) || true
if echo "$output" | jq -e '.success == true' >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Successfully pauses with valid JSON"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should successfully pause with valid JSON"
    echo "$output"
    fail_count=$((fail_count + 1))
fi

# Cleanup temporary test directory
rm -rf "$TEST_DIR"

# Test 4: Error when not in worktree
output=$(echo '{"ticket":"TEST-123","summary":"test"}' | cd /tmp && "$SCRIPT" 2>&1) || true
if echo "$output" | grep -q "Not a git worktree"; then
    echo -e "${GREEN}✓${NC} Detects when not in worktree"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should detect when not in worktree"
    echo "$output"
    fail_count=$((fail_count + 1))
fi

echo ""
echo "================================"
if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} ($pass_count/$((pass_count + fail_count)))"
    echo ""
    echo "Note: Full integration test requires actual worktree"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 1
fi
