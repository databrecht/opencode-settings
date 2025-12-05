#!/usr/bin/env bash
set -euo pipefail

# test-git-context.sh - Test git-context.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/git-context.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass_count=0
fail_count=0

assert_json_field() {
    local json="$1"
    local field="$2"
    local test_name="$3"
    
    local value
    value=$(echo "$json" | jq -r "$field" 2>/dev/null)
    
    if [[ "$value" != "null" && "$value" != "" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((pass_count++))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Field $field is null or missing"
        ((fail_count++))
    fi
}

echo "Testing git-context.sh..."
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

# Test 2: Script returns valid JSON from opencode config repo
output=$("$SCRIPT" "$HOME/.config/opencode" 2>&1)
if echo "$output" | jq empty 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Script returns valid JSON"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Script does not return valid JSON"
    echo "$output"
    ((fail_count++))
    exit 1
fi

# Test 3: Required fields exist
assert_json_field "$output" '.branch' "Has branch field"
assert_json_field "$output" '.status' "Has status object"
assert_json_field "$output" '.status.is_clean' "Has status.is_clean field"
assert_json_field "$output" '.status.staged.count' "Has staged count"
assert_json_field "$output" '.status.unstaged.count' "Has unstaged count"
assert_json_field "$output" '.status.untracked.count' "Has untracked count"
assert_json_field "$output" '.commits' "Has commits array"
assert_json_field "$output" '.remote.tracking' "Has remote tracking status"

# Test 4: Error handling for non-git directory
error_output=$("$SCRIPT" /tmp 2>&1) || true
if echo "$error_output" | grep -q "error"; then
    echo -e "${GREEN}✓${NC} Returns error for non-git directory"
    ((pass_count++))
else
    echo -e "${RED}✗${NC} Should return error for non-git directory"
    ((fail_count++))
fi

echo ""
echo "================================"
if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 1
fi
