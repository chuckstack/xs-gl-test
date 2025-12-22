# Example: Accounts Prototype

Minimal prototype to vet concepts for the next gl.je release (see `planning/next-release-v1.md`).

## Purpose

Validate the dual-interface pattern:
- http-nu serves both CLI and web from same handler
- xs for event storage
- Datastar for reactive web UI
- Nushell CLI as HTTP client

## Files

- `serve.nu` - http-nu handler (owns xs, serves both interfaces)
- `gl-cli.nu` - CLI client (dual-mode: executable and module)

## Run

```bash
# Terminal 1: xs server (from repo root)
xs serve .local/store

# Terminal 2: http-nu server (from repo root)
export XS_ADDR=.local/store
cat example/serve.nu | http-nu :3001 -

# Terminal 3: CLI (from repo root)
./example/gl-cli.nu account activate cash asset
./example/gl-cli.nu account list

# Or browser: http://localhost:3001
```

## Reset

```bash
rm -rf .local/store
```

## Next: Datastar Web UI

The web interface should mirror CLI capabilities using Datastar for reactivity.

### http-nu Features Used

**Embedded Modules** (via `use http-nu/... *`):
- `router` - Declarative routing with `route` and `dispatch`
- `html` - HTML DSL for generating markup
- `datastar` - SSE SDK for Datastar integration

**HTML DSL Pattern**:
```nushell
_div {id: "accounts"} {           # _tag starts element, closure for children
  _table {
    _tr { _th "Name" | +th "Type" }  # +tag appends sibling
    | +tr { _td "cash" | +td "asset" }
  }
}
```

**Datastar SSE Commands**:
- `to dstar-patch-element` - Update DOM elements by ID
- `to dstar-patch-signal` - Update reactive signals
- `from datastar-request $req` - Parse signals from request body

### Current State

- Index page renders with Datastar script and HTML DSL
- Account list loads via `@get('/accounts')` on page load
- Activate form wired with `@post('/account/activate')`

### TODO

- [ ] Activate form: patch account list after successful activate
- [ ] Add deactivate button per account row with `@post('/account/deactivate')`
- [ ] Real-time updates: SSE stream for live account changes
- [ ] Error handling: display validation errors via `dstar-patch-signal`
- [ ] Styling: inline styles via HTML DSL record syntax

### Pattern

Both CLI and web share the same http-nu routes. The `is-cli` check differentiates response format:
- CLI: JSON response (nushell records/tables)
- Web: Datastar SSE patches (`to dstar-patch-element | to sse`)

## Thoughts: When is a Handler Needed?

**http-nu responsibilities:**
- Validate request shape and business rules
- If conformant, append to xs
- Return the frame (includes event_id) as acknowledgment

**Write commands (activate, deactivate):**
- Validate → append → return frame. No handler needed.
- The append itself is the acknowledgment.

**Read commands (list, balances):**
- Project state from events.
- Can be done directly in http-nu or via handler-cached state.

**Handler needed when:**
- Write + immediate read in same operation (web UI updating a pane)
- Async processing after append
- Caching projections for performance

**CLI vs Web:**
```bash
# CLI: two separate commands
gl account activate cash asset   # returns frame (ack)
gl account list                  # projects state
```

```
# Web: single operation needs both
POST /account/activate
  → append event
  → project state (or handler does)
  → SSE patch updates UI
```

The web combines write + read in one operation. CLI separates them. This is why web may need handlers that CLI doesn't.
