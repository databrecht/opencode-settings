---
name: typescript-security
description: Security patterns for TypeScript. Use when handling credentials, file operations, external input, atomic writes, or implementing security-sensitive operations.
---

# TypeScript Security Guidelines

Security-critical patterns for TypeScript applications handling credentials, files, and external input.

## When Applied

- Handling credentials or sensitive data
- File operations (especially atomic writes)
- Validating external input
- Setting file permissions
- Preventing root execution
- Error handling with cleanup

## Rules

### Atomic File Operations

**Use atomic writes for critical data.** Prevents corruption if process dies mid-write.

```typescript
// ✅ DO
export function writeJsonSafe<T>(filePath: string, data: T): void {
  const tempPath = `${filePath}.${process.pid}.tmp`;

  try {
    const content = JSON.stringify(data, null, 2);
    JSON.parse(content); // Validate by round-tripping

    fs.writeFileSync(tempPath, content, { mode: 0o600 });
    fs.renameSync(tempPath, filePath); // Atomic on POSIX
    fs.chmodSync(filePath, 0o600);
  } catch (err) {
    try {
      if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
    } catch {}
    throw err;
  }
}

// ❌ DON'T
export function writeJson(filePath: string, data: any): void {
  fs.writeFileSync(filePath, JSON.stringify(data)); // Not atomic, not validated
}
```

**Key points:**

- Write to temp file first (`${filePath}.${process.pid}.tmp`)
- Validate content before committing (round-trip JSON.parse)
- Use `rename()` for atomic operation (POSIX guarantee)
- Clean up temp file on ANY error
- Set secure permissions immediately

### File Permissions

**Set secure file permissions for sensitive data.** Use 0600 for files, 0700 for directories.

```typescript
// ✅ DO
fs.writeFileSync(path, content, { mode: 0o600 }); // rw-------
fs.chmodSync(path, 0o600);

export function ensureSecureDir(dirPath: string): void {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true, mode: 0o700 });
  } else {
    fs.chmodSync(dirPath, 0o700);
  }
}

// ❌ DON'T
fs.writeFileSync(path, content); // Default permissions (644 - world readable!)
```

**Permission reference:**

- `0o600` for files: Owner read/write only (rw-------)
- `0o700` for directories: Owner read/write/execute only (rwx------)
- NEVER use default permissions for credentials/secrets

### Input Validation

**Validate external input before use.** Prevent injection attacks and data corruption.

```typescript
// ✅ DO
const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

export function validateEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

if (!validateEmail(input)) {
  throw new Error(`Invalid email: ${input}`);
}

// Validate JSON before processing
const content = JSON.stringify(data, null, 2);
JSON.parse(content); // Round-trip validation

// ❌ DON'T
// Use input directly without validation
const email = userInput;
saveToDatabase(email);
```

**What to validate:**

- Email addresses (regex)
- File paths (no traversal: `..`, absolute paths)
- JSON structures (round-trip parse)
- User input (whitelist allowed characters)
- API responses (schema validation)

### Root Prevention

**Prevent root execution (with container exception).** Running as root can leak credentials to other users.

```typescript
// ✅ DO
export function checkNotRoot(): void {
  if (process.getuid?.() === 0 && !isRunningInContainer()) {
    console.error("Error: Do not run as root");
    process.exit(1);
  }
}

function isRunningInContainer(): boolean {
  if (fs.existsSync("/.dockerenv")) return true;

  try {
    const cgroup = fs.readFileSync("/proc/1/cgroup", "utf8");
    if (/docker|lxc|containerd|kubepods/.test(cgroup)) return true;
  } catch {
    // Not on Linux - that's fine
  }

  return !!(process.env.CONTAINER || process.env.container);
}

// ❌ DON'T
// Allow root execution without checks
```

**Why containers are exempt:**

- Containers often run as root by design
- Container isolation provides security boundary
- Detect via `/.dockerenv`, `/proc/1/cgroup`, or env vars

### Error Handling with Cleanup

**Use try-catch with cleanup.** Ensures resources are cleaned up even on errors.

```typescript
// ✅ DO
export function safeOperation(filePath: string): void {
  const tempPath = `${filePath}.tmp`;

  try {
    fs.writeFileSync(tempPath, content);
    fs.renameSync(tempPath, filePath);
  } catch (err) {
    try {
      if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
    } catch {}
    throw err; // Re-throw original error
  }
}

// ❌ DON'T
export function unsafeOperation(filePath: string): void {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, content);
  fs.renameSync(tempPath, filePath);
  // Temp file leaks on error
}
```

**Pattern:**

1. Create resource (temp file, connection, handle)
2. Try operation
3. Catch errors → clean up resource → re-throw
4. Nested try-catch for cleanup (ignore cleanup failures)

### Graceful Fallbacks

**Provide graceful fallbacks.** Better UX than hard failures.

```typescript
// ✅ DO
export function readJsonSafe<T>(filePath: string): T | null {
  if (!fs.existsSync(filePath)) return null;

  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (err) {
    console.error(`Error reading ${filePath}:`, err);
    return null; // Graceful failure
  }
}

// ❌ DON'T
export function readJson<T>(filePath: string): T {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
  // Crashes on missing file or invalid JSON
}
```

**When to use:**

- File reads (return null on missing/corrupted)
- Optional features (degrade gracefully)
- Network requests (retry with exponential backoff)

**When NOT to use:**

- Required configuration (fail fast)
- Security checks (never ignore failures)
- Data corruption (better to crash than corrupt)

### Early Returns

**Return early for error cases.** Reduces nesting, clearer logic flow.

```typescript
// ✅ DO
export function process(input: string): Result {
  if (!input) return null;
  if (!validate(input)) return null;

  return performOperation(input);
}

// ❌ DON'T
export function process(input: string): Result {
  if (input) {
    if (validate(input)) {
      return performOperation(input);
    } else {
      return null;
    }
  } else {
    return null;
  }
}
```

**Benefits:**

- Fail-fast on invalid input
- Reduces nesting (max 1-2 levels)
- Happy path at bottom (most readable)
- Easier to spot missing validation

### Shell Escaping

**Escape strings for shell interpolation.** Prevent command injection.

```typescript
// ✅ DO
export function shellEscape(str: string): string {
  // Single quotes prevent ALL shell interpretation
  return `'${str.replace(/'/g, "'\\''")}'`;
}

const safePath = shellEscape(userInput);
execSync(`cat ${safePath}`);

// ❌ DON'T
execSync(`cat ${userInput}`); // Command injection vulnerability
```

**Why single quotes:**

- Prevent `$`, `` ` ``, `\`, `*`, `?` interpretation
- Only need to escape single quotes themselves
- Pattern: end quote, escaped quote, start quote (`'\\''`)

### Dry-Run Mode

**Provide dry-run mode for destructive operations.** Safe testing without side effects.

```typescript
// ✅ DO
export function launchProfile(profile: Profile, args: string[]): void {
  if (isDryRun()) {
    dryRunLog("Would launch", { profile: profile.name, args });
    return;
  }

  const child = spawn(binaryPath, args, { stdio: "inherit" });
  child.on("close", (code) => process.exit(code ?? 0));
}

// ❌ DON'T
// No dry-run capability
export function launchProfile(profile: Profile, args: string[]): void {
  const child = spawn(binaryPath, args, { stdio: "inherit" });
  child.on("close", (code) => process.exit(code ?? 0));
}
```

**Pattern:**

```typescript
// Environment variable or flag
export function isDryRun(): boolean {
  return process.env.DRY_RUN === "1" || process.argv.includes("--dry-run");
}

// Log what WOULD happen
export function dryRunLog(action: string, details: Record<string, any>): void {
  console.log(`[DRY RUN] ${action}:`, JSON.stringify(details, null, 2));
}
```

## Security Checklist

When implementing security-sensitive operations:

- ✅ Atomic writes for credentials/config
- ✅ File permissions (0600/0700)
- ✅ Input validation (whitelist, not blacklist)
- ✅ Root prevention (unless container)
- ✅ Error cleanup (try-catch-cleanup pattern)
- ✅ Graceful fallbacks (where appropriate)
- ✅ Early returns (fail-fast)
- ✅ Shell escaping (if using exec)
- ✅ Dry-run mode (for testing)
