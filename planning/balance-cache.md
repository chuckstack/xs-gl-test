# GL Balance Cache Strategy

## Problem

Projecting balances from the full `gl-fact` stream is O(n) - every query replays all frames.

## Solution

Handler maintains a single cached state frame with all account balances.

## Architecture

```
gl-fact topic               gl-state topic
┌─────────────────┐         ┌─────────────────────────────────┐
│ {cmd: "post"..} │ ──────► │ {balances: {Asset:Cash: 13500,  │
│ {cmd: "post"..} │ handler │  Equity:Opening: -10000, ...}}  │
│ {cmd: "post"..} │         └─────────────────────────────────┘
└─────────────────┘                  --ttl "head:1"
```

Note: `gl-fact` contains only validated, normalized entries (see `gl-validation.md`).

## Components

### Handler: `gl-state.register`

- Watches `gl-fact` topic (canonical ledger)
- On each `post`: recalculates all balances
- Appends full state to `gl-state` with `--ttl "head:1"`

### Topic: `gl-state`

- Single frame containing complete balance state
- TTL `head:1` ensures only latest is retained

### Query

```nu
# O(1) lookup - instant
.head gl-state | get meta.balances

# Single account
.head gl-state | get meta.balances.Asset:Cash
```

## TTL Strategy (Full System)

| Topic | TTL | Writer | Purpose |
|-------|-----|--------|---------|
| `gl-post` | forever | user | Raw input, audit trail |
| `gl-fact` | forever | validate handler | Canonical ledger |
| `gl-error` | forever | validate handler | Validation failures |
| `gl-state` | head:1 | state handler | Cached balances |

## Trade-offs

| Approach | Lookup | Storage | Complexity |
|----------|--------|---------|------------|
| Full projection | O(n) | Minimal | Simple |
| Topic per account | O(1) | Many topics | Moderate |
| **Single state frame** | O(1) | One frame | Moderate |

Single state frame chosen for:
- Simple topology (one cache topic)
- O(1) lookup via `.head`
- Acceptable for small/medium account counts

## Implementation Status

- [ ] Create `handler-state.nu`
- [ ] Register handler
- [ ] Update `gl.nu` to use cache for queries
- [ ] Add fallback to full projection if cache missing
