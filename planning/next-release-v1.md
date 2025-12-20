# gl.je Next Release Planning (v1)

**Date**: 2025-12-20
**Status**: Draft

## Overview

Transform gl.je from a local xs-only implementation into an http-nu centric web-enabled application with remote CLI support.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     http-nu server                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │
│  │   xs store  │  │   sqlite    │  │    handlers     │   │
│  │   (truth)   │◄─┤  (speed)    │◄─┤  (projections)  │   │
│  └─────────────┘  └─────────────┘  └─────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  REST API + Web UI (Datastar + HTML DSL)            │ │
│  │  JSON Schema validation per topic                   │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
              ▲                    ▲
              │ HTTP               │ HTTP
              │                    │
    ┌─────────┴───────┐   ┌───────┴─────────┐
    │  gl.nu (CLI)    │   │  Browser (Web)  │
    │  bash/nushell   │   │  Datastar SSE   │
    └─────────────────┘   └─────────────────┘
```

### Key Principles

- **http-nu centric**: Server owns xs store + sqlite, exposes all functionality via HTTP
- **All CLI is remote**: No local xs access; gl.nu is a thin HTTP client
- **xs is source of truth**: Append-only event log remains canonical
- **SQLite is optional optimization**: For speed-critical queries when projection cost is too high
- **CLI-first development**: Define capabilities in CLI, web reflects and adds discoverability

## Conventions

### Identifiers

Text-based identifiers instead of UUIDs:

```
cash, travel, test1, campaign-sammy, 2025-q1
```

Guidelines:
- Lowercase preferred (speed typing)
- Dashes preferred (10-key accessible, easier than underscore)
- No semantic encoding required (identifier `travel` with type `expense`, not required `expense-travel`)
- Uppercase and underscores valid but not convention

### Descriptions

Any identifier can have a description via the `describe` command. Latest description wins.

```nushell
gl describe cash "Primary operating account"
gl describe test1 "Q1 marketing pilot"
```

### Aliases

Renaming support via aliases (to be defined later).

## Hosting

### Instance Model

One instance = one key = one xs store + one sqlite file.

```
key: "acme-corp"
  → acme-corp.xs
  → acme-corp.sqlite
```

The key is the sole identifier for all access (website, API, password recovery). No customer/email abstraction at the instance level - each instance is independent. One email can manage multiple instances via their respective keys.

### Infrastructure Stack

```
[internet] → nginx (edge, routes by key) → NixOS/systemd/http-nu instances
```

- **Incus**: Hosts NixOS instances (snapshots, management, eventual clustering)
- **NixOS + systemd**: Per-instance isolation with minimal footprint
- **nginx**: Edge routing by key to appropriate instance
- **http-nu-oauth**: Authentication (github.com/cablehead/http-nu-oauth)

## Core Concepts

### Accounts

Standard double-entry accounts with types enum: asset, liability, equity, revenue, expense.

### Settings

User-configurable behavior modifiers (e.g., `first-of-year-day` for fiscal year start).

### Dimensions

Multi-dimensional accounting (similar to iDempiere). User-defined dimension types applied per-line in transactions.

Example types: entity, project, campaign, department, activity, bp.

### Posts

Double-entry transactions with optional dimensions per line.

```nushell
gl post [
  {account: "marketing", amount: 5000, dimensions: {project: "test1", campaign: "sammy"}}
  {account: "cash", amount: -5000}
]
```

Amounts is a signed integer in cents. Sum must equal zero.

NOTE: eventually we will need to account for (group by) 'entity' when summing to zero - to be addressed later. in the short term, entities are a simple dimension like any other.

## Event Model

### Commands

| Command | Applies To | Purpose |
|---------|------------|---------|
| `activate` | account, setting, dimension | Bring into existence |
| `deactivate` | account, setting, dimension | Mark inactive |
| `describe` | any identifier | Set/update description |
| `set` | setting | Set value |
| `create` | dimension-type | Define new dimension type |
| `post` | transaction | Record balanced entry |

### Topics (xs streams)

| Topic | TTL | Purpose |
|-------|-----|---------|
| `gl-post` | forever | Raw transaction input |
| `gl-fact` | forever | Validated, normalized ledger |
| `gl-error` | forever | Validation failures |
| `gl-state` | head:1 | Cached balances |
| `gl-account` | forever | Account events |
| `gl-setting` | forever | Setting events |
| `gl-dimension-type` | forever | Dimension type events |
| `gl-dimension` | forever | Dimension events |
| `gl-describe` | forever | Description events |

## API Surface

Resource-specific endpoints:

```
# Accounts
POST /api/account/activate
POST /api/account/deactivate
GET  /api/account/list

# Settings
POST /api/setting/activate
POST /api/setting/deactivate
POST /api/setting/set
GET  /api/setting/list

# Dimension Types
POST /api/dimension-type/create
POST /api/dimension-type/delete
GET  /api/dimension-type/list

# Dimensions
POST /api/dimension/activate
POST /api/dimension/deactivate
GET  /api/dimension/list

# Descriptions (universal)
POST /api/describe

# Transactions
POST /api/post
GET  /api/ledger
GET  /api/balances
GET  /api/trial-balance
```

JSON Schema validation for all POST payloads.

## CLI Design

Dual-mode pattern (see `planning/nushell-module-bash-command-reuse/`):
- Executable: `./gl.nu account activate cash asset`
- Module: `use gl.nu *; gl account activate cash asset`

```bash
# Accounts
gl account activate cash asset
gl account deactivate old-account
gl account list

# Descriptions (any identifier)
gl describe cash "Primary operating account"

# Settings
gl setting activate first-of-year-day
gl setting set first-of-year-day 04-01
gl setting list

# Dimension Types
gl dimension-type create project
gl dimension-type list

# Dimensions
gl dimension activate project test1
gl dimension list

# Transactions
gl post [{account: cash, amount: 10000}, ...]
gl ledger
gl balances
gl trial-balance
```

## Web UI

- **Left pane**: Topic browser (posts, accounts, dimensions, settings)
- **Right pane**: Read/write interaction area
- **Datastar SSE**: Real-time updates

## Dependencies

Submodules:
- `xs/` - cablehead/xs
- `http-nu/` - cablehead/http-nu

http-nu features: routing module, HTML DSL, Datastar SSE SDK, JSON Schema validation, HTTP/2.

## Implementation Phases

### Phase 1: Foundation
- [ ] http-nu server scaffold
- [ ] Basic routing for accounts API
- [ ] gl.nu as HTTP client
- [ ] Dual-mode CLI pattern

### Phase 2: Core Features
- [ ] Settings, dimensions, dimension-types
- [ ] Posts with dimensions
- [ ] Describe command
- [ ] JSON Schema validation

### Phase 3: Web UI
- [ ] Left/right pane layout
- [ ] CRUD views for all entity types
- [ ] Trial balance view

### Phase 4: Reactivity
- [ ] Datastar SSE integration
- [ ] Real-time balance updates

### Phase 5: Optimization
- [ ] SQLite projection handlers
- [ ] Query optimization for large ledgers

## Open Questions

1. Dimension type hierarchies?
2. Reports beyond trial balance?
3. Alias implementation details?

## Design Decisions

### Topic Prefix: gl-

Decision: Keep the `gl-` prefix on all xs topics.

Rationale:
- Short and easy to include
- Allows other modules to add topics with different prefixes
- Avoids potential xs reserved topic name conflicts
- Matches CLI command prefix (`gl`)

## References

- http-nu-oauth: github.com/cablehead/http-nu-oauth
