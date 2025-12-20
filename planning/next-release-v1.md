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

## Key-Based Multi-Tenancy

Each "key" represents an isolated ledger instance:

```
key: "acme-corp"
  → ~/.local/share/gl.je/acme-corp.xs
  → ~/.local/share/gl.je/acme-corp.sqlite
```

The key serves as:
- Routing identifier (which ledger?)
- Storage identifier (file names for xs + sqlite)

**Hosting considerations**: To be discussed in separate planning document.

CHUCK: hosting comments
- your comment: Each 'key' represents an isolated ledger 'instance' (this is perfect)
- assume one 'instance' is equal to one store (xs + sqlite)
- an instance has a 'key'
- The key is vital because it will be the only way to access stuff (example: website, password recovery email, etc...)
- customer can have more than one account/store; however, from our perspective, we do not really care who owns the account because we will treat each instance independently
- said another way: there is no concept of multiple stores or instances for a single customer/email address.
- different stores can be managed from the same email address because each store has a unique key that will uniquely identify the appropriate context
- said another way:
  - there can be a one to many relationship between any one email and instances
  - instances are always identified by its key
- the goal is to use the smallest possible footprint to host a instance.
  - my preference is to use nixos=>systemd as a way to serve, secure, and isolate instances (I believe this is smaller and just as secure as an incus container - to be discussed)
  - i am thinking we should use nginx as way to route the right key to the right instance
- it is important to note that http-nu has an oath implementation (https://github.com/cablehead/http-nu-oauth)
- we will use incus to provide multiple nixos instances (allows for snapshot and other features to manage between 1 and x nixos servers)
- we will eventually use incus clustering to support multiple incus nodes.

## Core Concepts

### Accounts

Standard double-entry accounts with types: asset, liability, equity, revenue, expense.

### Settings

User-configurable behavior modifiers.

Example: `first-of-year-day` to define fiscal year start.

Settings support: activate, deactivate, set-value operations.

### Dimensions (User-Defined)

Multi-dimensional accounting similar to iDempiere. Users define their own dimension types.

Example dimension types:
- entity
- project
- campaign
- department
- activity
- business partner (bp)

Dimensions are:
- User-defined (not a fixed list)
- Applied per-line in transactions
- Optional on any posting line

### Posts (Transactions)

Double-entry transactions with optional dimensions per line.

```nushell
gl post [
  {account: "Expense:Marketing", amount: 5000, dimensions: {project: "test1", campaign: "sammy"}}
  {account: "Asset:Cash", amount: -5000}
]
```

Amounts in cents (integer minor units). Sum must equal zero.

## API Surface

Resource-specific endpoints with consistent verbs:

### Accounts
```
POST /api/account/activate
POST /api/account/deactivate
GET  /api/account/list
```

### Settings
```
POST /api/setting/activate
POST /api/setting/deactivate
POST /api/setting/set
GET  /api/setting/list
```

### Dimension Types
```
POST /api/dimension-type/create    # create "project" dimension type
POST /api/dimension-type/delete
GET  /api/dimension-type/list
```

### Dimensions
```
POST /api/dimension/activate       # activate project "test1"
POST /api/dimension/deactivate
GET  /api/dimension/list
GET  /api/dimension/list?type=project
```

### Transactions
```
POST /api/post
GET  /api/ledger
GET  /api/balances
GET  /api/trial-balance
```

### Validation

JSON Schema validation for all POST payloads to ensure proper shape per topic.

## Web UI

### Layout

- **Left pane**: Topic browser (posts, accounts, dimensions, settings)
- **Right pane**: Read/write interaction area

### Approach

- Web reflects CLI capabilities
- Web adds convenience via topic hints and discoverability
- Datastar SSE for real-time updates (balance changes, new posts)

## CLI Design

### Dual-Mode Pattern

gl.nu works as both:
- Direct executable: `./gl.nu post ...`
- Importable module: `use gl.nu *; gl post ...`

Uses the main wrapper pattern from `planning/nushell-module-bash-command-reuse/`.

### Commands

```bash
# Accounts
gl account activate "Asset:Cash" "asset"
gl account deactivate "Asset:OldAccount"
gl account list

# Settings
gl setting activate "first-of-year-day"
gl setting set "first-of-year-day" "04-01"
gl setting list

# Dimension Types
gl dimension-type create "project"
gl dimension-type list

# Dimensions
gl dimension activate "project" "test1"
gl dimension list
gl dimension list --type project

# Transactions
gl post [{account: "Asset:Cash", amount: 10000}, ...]
gl ledger
gl balances
gl trial-balance
```

## Event Topics (xs streams)

| Topic | TTL | Purpose |
|-------|-----|---------|
| `gl-post` | forever | Raw transaction input |
| `gl-fact` | forever | Validated, normalized ledger |
| `gl-error` | forever | Validation failures |
| `gl-state` | head:1 | Cached balances |
| `gl-account` | forever | Account activations/deactivations |
| `gl-setting` | forever | Setting changes |
| `gl-dimension-type` | forever | Dimension type definitions |
| `gl-dimension` | forever | Dimension activations |

## Dependencies

### Submodules

- `xs/` - cablehead/xs (event streaming store)
- `http-nu/` - cablehead/http-nu (web server + routing + HTML DSL + Datastar SDK)

### http-nu Features Used

- Embedded routing module
- HTML DSL for server-rendered views
- Datastar SSE SDK for reactivity
- JSON Schema validation (planned)
- HTTP/2 + graceful shutdown

## Open Questions

1. **Hosting model**: Self-hosted vs managed service vs both?
2. **Authentication**: How do remote CLI users authenticate?
3. **Key routing**: How does the key map to hosted instances?
4. **Dimension inheritance**: Can dimension types have hierarchies?
5. **Reporting**: What reports beyond trial balance?

## Implementation Phases

### Phase 1: Foundation
- [ ] http-nu server scaffold
- [ ] Basic routing for accounts API
- [ ] gl.nu as HTTP client
- [ ] Dual-mode CLI pattern

### Phase 2: Core Features
- [ ] Settings implementation
- [ ] Dimension types and dimensions
- [ ] Posts with dimensions
- [ ] JSON Schema validation

### Phase 3: Web UI
- [ ] Left/right pane layout
- [ ] Account management view
- [ ] Transaction entry form
- [ ] Trial balance view

### Phase 4: Reactivity
- [ ] Datastar SSE integration
- [ ] Real-time balance updates
- [ ] Live transaction feed

### Phase 5: Optimization
- [ ] SQLite projection handlers
- [ ] Query optimization for large ledgers

---

CHUCK: there are some additional notes
- because of the nature of this application and event data stores, we will not use the typical sql, uu-style keys.
- instead we will use text - example: asset-2025 (where lowercase and separated by dash)
  - easier for humans to reason about
  - easier to add/reference in work instructions
  - just as easy for AI to work with
  - lower case for speed typing
  - dashes to allow for 10-key typing
  - dashes because people can typically more easily reach for this key than underscore
  - it is perfectly valid to use uppercase and underscores - they are just not the convention
- we will need to eventually need to account for the concept of an 'alias' to allow for renaming something. this concept can be defined later.

*This document will be iteratively refined as design decisions are made.*
