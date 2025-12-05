#!/usr/bin/env bash
set -euo pipefail

# test-linear-format.sh - Test linear-format.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/linear-format.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass_count=0
fail_count=0

echo "Testing linear-format.sh..."
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

# Test 2: Validates JSON
output=$(echo "invalid" | "$SCRIPT" 2>&1 || true)
if [[ "$output" == *"Invalid JSON"* ]]; then
    echo -e "${GREEN}✓${NC} Validates JSON input"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should validate JSON"
    echo "$output"
    fail_count=$((fail_count + 1))
fi

# Test 3: Formats valid ticket
test_json='{"identifier":"ENG-198","title":"Add aggregates support","state":{"name":"In Progress"},"priority":2,"assignee":{"name":"John Doe"},"url":"https://linear.app/team/issue/ENG-198","description":"Implement aggregates for event sourcing"}'

output=$(echo "$test_json" | "$SCRIPT" 2>&1 || true)
if [[ "$output" == *"ENG-198"* ]]; then
    echo -e "${GREEN}✓${NC} Formats ticket identifier"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should format ticket identifier"
    echo "$output"
    fail_count=$((fail_count + 1))
fi

if [[ "$output" == *"Add aggregates support"* ]]; then
    echo -e "${GREEN}✓${NC} Formats ticket title"
    pass_count=$((pass_count + 1))
else
    echo -e "${GREEN}✗${NC} Should format ticket title"
    fail_count=$((fail_count + 1))
fi

if [[ "$output" == *"High"* ]]; then
    echo -e "${GREEN}✓${NC} Maps priority correctly"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Should map priority to label"
    fail_count=$((fail_count + 1))
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
