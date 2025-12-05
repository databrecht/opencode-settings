#!/usr/bin/env bash
set -euo pipefail

# test-worktree-resume.sh - Test worktree-resume.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/worktree-resume.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass_count=0
fail_count=0

echo "Testing worktree-resume.sh..."
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

# Test 2: Error when no worktree.md exists
output=$("$SCRIPT" /tmp 2>&1) || true
if echo "$output" | grep -q "No paused session"; then
    echo -e "${GREEN}✓${NC} Detects missing worktree.md"
    ((pass_count++)) || true
else
    echo -e "${RED}✗${NC} Should detect missing worktree.md"
    echo "$output"
    ((fail_count++)) || true
fi

# Test 3: Parse valid worktree.md
# Create temporary test directory
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/.opencode"

cat > "$TEST_DIR/.opencode/worktree.md" <<'EOF'
---
ticket: TEST-123
branch: bdr/TEST-123/test-feature
paused_at: 2025-12-05T10:00:00Z
summary: Testing resume functionality
---

# Test Session

Some content here.
EOF

output=$("$SCRIPT" "$TEST_DIR" 2>&1)
if echo "$output" | jq empty 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Parses valid worktree.md"
    ((pass_count++)) || true
    
    # Verify fields
    ticket=$(echo "$output" | jq -r '.ticket')
    if [[ "$ticket" == "TEST-123" ]]; then
        echo -e "${GREEN}✓${NC} Extracts ticket correctly"
        ((pass_count++)) || true
    else
        echo -e "${RED}✗${NC} Failed to extract ticket"
        ((fail_count++)) || true
    fi
else
    echo -e "${RED}✗${NC} Failed to parse worktree.md"
    echo "$output"
    ((fail_count++)) || true
fi

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "================================"
if [[ $fail_count -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} ($pass_count/$((pass_count + fail_count)))"
    exit 1
fi
