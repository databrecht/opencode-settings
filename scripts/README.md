# OpenCode Scripts

Non-interactive scripts that handle mechanical operations for OpenCode, returning JSON for LLM consumption.

## Design Principles

1. **Non-interactive**: No user prompts, all input via arguments
2. **JSON output**: Structured data on stdout for easy parsing
3. **Error handling**: Exit codes + JSON error messages on stderr
4. **Testable**: Pure input/output, no side effects in query scripts
5. **Fast**: Optimized for minimal execution time

## Scripts

- `worktree-status.sh` - Get complete worktree environment state
- `git-context.sh` - Get git repository state (branch, changes, commits)
- `worktree-create.sh` - Create new worktree with ticket
- `worktree-pause.sh` - Pause current worktree session
- `worktree-resume.sh` - Resume paused worktree session
- `linear-format.sh` - Format Linear ticket data for display

## Testing

Each script has a corresponding test file: `test-<script-name>.sh`

Run all tests: `./run-tests.sh`
