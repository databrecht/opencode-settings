#!/usr/bin/env bash
set -euo pipefail

# run-tests.sh - Run all script tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenCode Scripts Test Suite${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Find all test scripts
test_scripts=()
for script in "$SCRIPT_DIR"/test-*.sh; do
    if [[ -f "$script" && -x "$script" ]]; then
        test_scripts+=("$script")
    fi
done

if [[ ${#test_scripts[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No test scripts found${NC}"
    exit 0
fi

echo -e "Found ${#test_scripts[@]} test script(s)\n"

# Run each test
pass_count=0
fail_count=0

for test_script in "${test_scripts[@]}"; do
    test_name=$(basename "$test_script" .sh)
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}Running: $test_name${NC}"
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
    
    if "$test_script"; then
        ((pass_count++))
        echo ""
    else
        ((fail_count++))
        echo -e "${RED}Failed: $test_name${NC}"
        echo ""
    fi
done

# Summary
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

total=$((pass_count + fail_count))
echo -e "Total: $total"
echo -e "${GREEN}Passed: $pass_count${NC}"

if [[ $fail_count -gt 0 ]]; then
    echo -e "${RED}Failed: $fail_count${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
