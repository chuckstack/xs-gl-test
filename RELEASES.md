# Releases

## 20251211

Initial implementation of event-sourced general ledger with validation and caching.

### Features

- **Multi-topic architecture**: Raw input (`gl-post`) separated from canonical ledger (`gl-fact`), with error tracking (`gl-error`) and cached state (`gl-state`)
- **Server-side validation handler** (`handler-validate.nu`):
  - Validates required fields for all commands
  - Validates account types (asset, liability, equity, revenue, expense)
  - Validates postings balance (sum = 0)
  - Normalizes float amounts to integer cents
  - Rejects duplicate account activation
  - Rejects deactivating accounts with non-zero balance
- **Balance cache handler** (`handler-state.nu`):
  - Maintains cached balances in `gl-state` with TTL `head:1`
  - O(1) balance lookups via `.head gl-state`
  - Updates on both `activate` and `post` commands
- **Query commands**:
  - `gl balances` - O(1) cached lookup with projection fallback
  - `gl ledger` - view canonical ledger
  - `gl errors` - view validation failures
  - `gl stream` - view raw input

### Files

- `handler-validate.nu` - validation and normalization handler
- `handler-state.nu` - balance cache handler
- `gl.nu` - updated commands and queries
- `example.nu` - runnable example with error cases
