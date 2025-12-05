#!/usr/bin/env bash
set -euo pipefail

# test-worktree-status.sh - Test worktree-status.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/worktree-status.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

# Test helper
assert_json_field() {
    local json="$1"
    local field="$2"
    local expected_type="$3"
    local test_name="$4"
    
    local actual
    actual=$(echo "$json" | jq -r "($field) | type")
    
    if [[ "$actual" == "$expected_type" ]] || [[ "$expected_type" == "*" && "$actual" != "null" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((pass_count++)) || true
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected type: $expected_type"
        echo "  Got type: $actual"
        ((fail_count++)) || true
    fi
}

echo "Testing worktree-status.sh..."
echo ""

# Test 1: Script exists and is executable
if [[ -x "$SCRIPT" ]]; then
    echo -e "${GREEN}✓${NC} Script is executable"
    ((pass_count++)) || true
else
    echo -e "${RED}✗${NC} Script is not executable"
    ((fail_count++)) || true
    exit 1
fi

# Test 2: Script returns valid JSON
output=$("$SCRIPT" 2>&1)
if echo "$output" | jq empty 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Script returns valid JSON"
    ((pass_count++)) || true
else
    echo -e "${RED}✗${NC} Script does not return valid JSON"
    echo "$output"
    ((fail_count++)) || true
    exit 1
fi

# Test 3: Required fields exist
assert_json_field "$output" '.location' "string" "Has location field"
assert_json_field "$output" '.workspace_root' "string" "Has workspace_root field"
assert_json_field "$output" '.paused_worktrees' "array" "Has paused_worktrees array"
assert_json_field "$output" '.active_worktrees' "array" "Has active_worktrees array"
assert_json_field "$output" '.config' "object" "Has config object"

# Test 4: Config has required fields
assert_json_field "$output" '.config.repo_folder' "string" "Config has repo_folder"
assert_json_field "$output" '.config.worktrees_folder' "string" "Config has worktrees_folder"

echo ""
echo "================================"
if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 1
fi
