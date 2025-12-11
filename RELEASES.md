# Releases

## 20251211-2

Handler restart resilience and documentation.

### Changes

- **Handler `resume_from`**: Handlers now resume from last processed frame on restart instead of only processing new frames
  - Uses `.head <output-topic> | $in.id` pattern
  - Ensures unprocessed frames are handled after restart/re-registration
- **Documentation**: Added `example.nu` reference to README with idempotency warning
- **Bug fixes**: Fixed `.cat` topic flag (`-T`), handler registration (`.append` not `.register`)

---

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
