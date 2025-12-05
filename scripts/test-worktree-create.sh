#!/usr/bin/env bash
set -euo pipefail

# test-worktree-create.sh - Test worktree-create.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/worktree-create.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass_count=0
fail_count=0

echo "Testing worktree-create.sh..."
echo ""

# Test 1: Script exists and is executable
if [[ -x "$SCRIPT" ]]; then
    echo -e "${GREEN}✓${NC} Script is executable"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Script is not executable"
    ((fail_count++))
    exit 1
fi

# Test 2: Usage message when no arguments
output=$("$SCRIPT" 2>&1) || true
if echo "$output" | grep -q "Usage:"; then
    echo -e "${GREEN}✓${NC} Shows usage when no arguments"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Should show usage when no arguments"
    ((fail_count++))
fi

# Test 3: Validates ticket ID format
output=$("$SCRIPT" "invalid" "test" 2>&1) || true
if echo "$output" | grep -q "Invalid ticket ID"; then
    echo -e "${GREEN}✓${NC} Validates ticket ID format"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Should validate ticket ID format"
    echo "$output"
    ((fail_count++))
fi

# Test 4: Validates slug format
output=$("$SCRIPT" "ENG-123" "Invalid_Slug" 2>&1) || true
if echo "$output" | grep -q "Invalid slug"; then
    echo -e "${GREEN}✓${NC} Validates slug format"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Should validate slug format"
    echo "$output"
    ((fail_count++))
fi

# Test 5: Error when not in workspace
output=$(cd /tmp && "$SCRIPT" "ENG-123" "test" 2>&1) || true
if echo "$output" | grep -q "Not in a workspace"; then
    echo -e "${GREEN}✓${NC} Detects when not in workspace"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Should detect when not in workspace"
    echo "$output"
    ((fail_count++))
fi

echo ""
echo "================================"
if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} ($pass_count/$((pass_count + fail_count)))"
    echo ""
    echo "Note: Full integration test requires actual workspace setup"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 1
fi
