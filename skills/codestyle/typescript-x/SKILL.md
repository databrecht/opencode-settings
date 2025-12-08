---
name: typescript-x
description: Base TypeScript patterns for all projects. ESM imports, type safety, code organization, naming conventions. Use when writing .ts files or reviewing TypeScript code.
---

# TypeScript Code Style Guidelines

Core TypeScript patterns for maintainable, type-safe code.

## When Applied

- Writing TypeScript files (\*.ts)
- Reviewing TypeScript code
- Working with ESM modules
- Designing APIs and type hierarchies

## Rules

### ESM Module System

**Always use ESM imports, never `require()`.** This is mandatory for ESM projects (`"type": "module"`).

```typescript
// ✅ DO
import { readProfiles } from "./profiles.js";
import type { Profile } from "./types.js";

// ❌ DON'T
const { readProfiles } = require("./profiles.js");
```

**Always include `.js` extension in imports.** ESM requires explicit extensions.

```typescript
// ✅ DO
import { readProfiles } from "./profiles.js";

// ❌ DON'T
import { readProfiles } from "./profiles";
```

**Separate type imports from value imports.**

```typescript
// ✅ DO
import type { Profile, OpenCodeProfile } from "./types.js";
import { isOpenCodeProfile } from "./types.js";

// ❌ DON'T
import { Profile, isOpenCodeProfile } from "./types.js";
```

### Type Safety

**Define interfaces before implementations.**

```typescript
// ✅ DO
export interface OpenCodeAuthProvider {
  provider: string;
  type: "oauth" | "api";
  email?: string;
  expiresAt?: number;
}

export function parseProviders(data: any): OpenCodeAuthProvider[] {
  // Implementation
}

// ❌ DON'T
export function parseProviders(data: any): any[] {
  // No type safety
}
```

**Use explicit return types for public functions.**

```typescript
// ✅ DO
export function getAuthPath(profileId: string): string {
  return path.join(dir, `${profileId}.json`);
}

// ❌ DON'T
export function getAuthPath(profileId: string) {
  return path.join(dir, `${profileId}.json`);
}
```

**Use type guards for discriminated unions.**

```typescript
// ✅ DO
export function isOpenCodeProfile(
  profile: Profile,
): profile is OpenCodeProfile {
  return profile.tool === "opencode";
}

// Usage
if (isOpenCodeProfile(profile)) {
  // TypeScript knows profile is OpenCodeProfile here
  launchOpenCode(profile);
}

// ❌ DON'T
if (profile.tool === "opencode") {
  // TypeScript doesn't narrow the type
  launchOpenCode(profile as OpenCodeProfile);
}
```

**Use generic types with constraints.**

```typescript
// ✅ DO
export function writeJsonSafe<T>(filePath: string, data: T): void {
  const content = JSON.stringify(data, null, 2);
  // ...
}

export function readJsonSafe<T>(filePath: string): T | null {
  // ...
}

// ❌ DON'T
export function writeJsonSafe(filePath: string, data: any): void {
  // Loses type information
}
```

### Code Organization

**Use section headers for file organization.**

```typescript
// ✅ DO
// =============================================================================
// OpenCode Auth Detection
// =============================================================================

export interface OpenCodeAuthProvider {}
export function readOpenCodeAuth(): Record<string, any> | null {}

// =============================================================================
// Auth Backup & Restore
// =============================================================================

export function backupOpenCodeAuth(profileId: string): void {}
export function restoreOpenCodeAuth(profileId: string): void {}

// ❌ DON'T
// Everything mixed together without clear sections
```

**Standard file structure order:**

```typescript
// 1. File-level JSDoc
/**
 * OpenCode profile management and launching.
 */

// 2. Imports (grouped)
import fs from "node:fs";
import path from "node:path";
import type { Profile } from "./types.js";
import { getDir } from "./constants.js";

// 3. Constants
const COLUMN_SPACING = 2;

// 4. Types and Interfaces
export interface Config {}

// 5. Implementation Functions
export function process(): void {}
```

**Types before implementations in same file.**

```typescript
// ✅ DO
export interface FormatOptions {
  spacing?: number;
  useBold?: boolean;
}

export function format(text: string, options: FormatOptions): string {
  // Implementation
}

// ❌ DON'T
export function format(text: string, options: any): string {
  // Implementation
}

interface FormatOptions {} // Defined after use
```

### Constants and Immutability

**Use `as const` for object constants.**

```typescript
// ✅ DO
export const TREE_CHARS = {
  branch: "├─",
  last: "└─",
  indent: "   ",
} as const;

// Type: { readonly branch: "├─"; readonly last: "└─"; ... }

// ❌ DON'T
export const TREE_CHARS = {
  branch: "├─",
  last: "└─",
  indent: "   ",
};
// Type: { branch: string; last: string; ... } (mutable)
```

**Define lookup tables as const records.**

```typescript
// ✅ DO
const PROVIDERS: Record<Provider, ProviderInfo> = {
  anthropic: { name: 'Anthropic', envVar: 'ANTHROPIC_API_KEY' },
  openai: { name: 'OpenAI', envVar: 'OPENAI_API_KEY' },
};

function getProviderInfo(provider: Provider): ProviderInfo {
  return PROVIDERS[provider] ?? defaultInfo;
}

// ❌ DON'T
const providers = new Map();
providers.set('anthropic', { ... });
// Verbose, not type-safe
```

### Naming Conventions

**Use descriptive, verb-first function names.**

```typescript
// ✅ DO
export function readOpenCodeAuth(): Record<string, any> | null;
export function writeOpenCodeAuth(data: Record<string, any>): void;
export function parseOpenCodeProviders(data: any): Provider[];
export function backupOpenCodeAuth(id: string): void;

// ❌ DON'T
export function auth(): any;
export function save(data: any): void;
export function providers(data: any): any[];
```

**Type guards use `is*` predicates.**

```typescript
// ✅ DO
export function isClaudeProfile(profile: Profile): profile is ClaudeProfile {
  return profile.tool === "claude";
}

export function isRunningInContainer(): boolean {
  return fs.existsSync("/.dockerenv");
}

// ❌ DON'T
export function checkIfClaudeProfile(profile: Profile): boolean {
  return profile.tool === "claude";
}
```

**Path getters use `get*Path` pattern.**

```typescript
// ✅ DO
export function getKeyFilePath(profileId: string): string;
export function getConfigFilePath(profileId: string): string;
export function getAuthBackupPath(profileId: string): string;

// ❌ DON'T
export function keyFile(profileId: string): string;
export function configPath(profileId: string): string;
```

**Boolean flags use `use`, `is`, or `has` prefix.**

```typescript
// ✅ DO
interface FormatOptions {
  useBold?: boolean;
  useUnderline?: boolean;
}

interface AuthProvider {
  hasKey: boolean;
}

const isMultiProvider = providers.length > 1;

// ❌ DON'T
interface FormatOptions {
  bold?: boolean;
  underline?: boolean;
}
```

### Function Signatures

**Use default parameters instead of overloads.**

```typescript
// ✅ DO
export function formatTreeItem(
  text: string,
  isLast: boolean,
  indentLevel: number = 0,
): string {
  // ...
}

// ❌ DON'T
export function formatTreeItem(text: string, isLast: boolean): string;
export function formatTreeItem(
  text: string,
  isLast: boolean,
  indentLevel: number,
): string;
export function formatTreeItem(
  text: string,
  isLast: boolean,
  indentLevel?: number,
): string {
  // ...
}
```

**Use options objects for 3+ parameters.**

```typescript
// ✅ DO
interface FormatOptions {
  columnSpacing?: number;
  activeMarker?: "●" | "← active";
  useBold?: boolean;
  useUnderline?: boolean;
}

export function formatProfile(
  profile: Profile,
  isActive: boolean,
  options: FormatOptions = {},
): string[] {
  const { columnSpacing = 2, activeMarker = "●" } = options;
  // ...
}

// ❌ DON'T
export function formatProfile(
  profile: Profile,
  isActive: boolean,
  columnSpacing?: number,
  activeMarker?: string,
  useBold?: boolean,
  useUnderline?: boolean,
): string[] {
  // Too many parameters!
}
```

**Optional parameters last.**

```typescript
// ✅ DO
export function backup(profileId: string, selectedProviders?: string[]): void;

// ❌ DON'T
export function backup(selectedProviders?: string[], profileId: string): void;
```

### Array and Object Operations

**Use functional methods over loops.**

```typescript
// ✅ DO
export function formatTreeItems(
  items: string[],
  indentLevel: number = 0,
): string[] {
  return items.map((item, i) =>
    formatTreeItem(item, i === items.length - 1, indentLevel),
  );
}

const filtered = Object.fromEntries(
  Object.entries(data).filter(([key]) => selected.includes(key)),
);

// ❌ DON'T
export function formatTreeItems(
  items: string[],
  indentLevel: number = 0,
): string[] {
  const result = [];
  for (let i = 0; i < items.length; i++) {
    result.push(formatTreeItem(items[i], i === items.length - 1, indentLevel));
  }
  return result;
}
```

**Use optional chaining and nullish coalescing.**

```typescript
// ✅ DO
const email =
  provData?.type === "oauth" && provData?.email ? `<${provData.email}>` : "";
const width = widths[i] ?? 0;
const alignment = alignments[i] ?? "left";

// ❌ DON'T
const email =
  provData && provData.type === "oauth" && provData.email
    ? `<${provData.email}>`
    : "";
const width = widths[i] !== undefined ? widths[i] : 0;
```

**Prefer spread over Object.assign.**

```typescript
// ✅ DO
const env: NodeJS.ProcessEnv = {
  ...process.env,
  CODE_SWITCHER_ACTIVE: "1",
};

// ❌ DON'T
const env = Object.assign({}, process.env, {
  CODE_SWITCHER_ACTIVE: "1",
});
```

### Documentation

**JSDoc for all public functions with WHY explanations.**

```typescript
// ✅ DO
/**
 * Atomic JSON write: temp file → validate → rename.
 * Prevents corruption if process dies mid-write.
 * Sets 0600 permissions (owner read/write only).
 * Cleans up temp file on any error.
 */
export function writeJsonSafe<T>(filePath: string, data: T): void {
  // ...
}

// ❌ DON'T
// Write JSON to file
export function writeJsonSafe<T>(filePath: string, data: T): void {
  // ...
}
```

**Document edge cases and exceptions.**

```typescript
// ✅ DO
/**
 * Refuse to run as root (credentials could leak to other users).
 * Exception: containers often run as root by design.
 */
export function checkNotRoot(): void {
  if (process.getuid?.() === 0 && !isRunningInContainer()) {
    console.error("Error: Do not run as root");
    process.exit(1);
  }
}

// ❌ DON'T
// Check if root
export function checkNotRoot(): void {}
```
