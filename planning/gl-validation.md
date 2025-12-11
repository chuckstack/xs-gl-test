# GL Validation Strategy

## Overview

Move validation from client-side (`gl.nu`) to server-side (handler). Raw input goes to staging topic, handler validates and promotes to canonical ledger.

## Topics

| Topic | TTL | Writer | Purpose |
|-------|-----|--------|---------|
| `gl-post` | forever | user | Raw input, audit trail |
| `gl-fact` | forever | handler | Canonical, normalized ledger |
| `gl-error` | forever | handler | Invalid posts with errors |

## Flow

```
gl-post                        gl-fact
┌─────────────────────┐        ┌──────────────────────────────┐
│ {cmd: "post",       │        │ {cmd: "post",                │
│  amount: 100.00}    │ ─────► │  amount: 10000,              │
│                     │ valid  │  source_id: "abc123"}        │
└─────────────────────┘        └──────────────────────────────┘
         │
         │ invalid
         ▼
┌─────────────────────────────┐
│ gl-error                    │
│ {error: "does not balance", │
│  source_id: "abc123"}       │
└─────────────────────────────┘
```

## Handler Responsibilities

1. Watch `gl-post` topic
2. Validate:
   - Required fields present
   - Valid account types (activate)
   - Lines sum to zero (post)
3. Normalize:
   - Convert float amounts to integer cents
4. On valid: append to `gl-fact` with `source_id`
5. On invalid: append to `gl-error` with `source_id` and `error`

## Projections

- Read from `gl-fact` only (clean, normalized data)
- `gl-post` preserved for audit/debugging
- `gl-error` for monitoring validation failures

## Implementation Status

- [x] Create `handler-validate.nu`
- [x] Update `gl.nu` to append to `gl-post` instead of `gl`
- [x] Update projections to read from `gl-fact`
- [x] Test validation and normalization
