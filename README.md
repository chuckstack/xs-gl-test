# gl.je - Event-Sourced Accounting General Ledger

A minimal double-entry accounting system built on [xs](https://github.com/cablehead/xs) (cross.stream) and [Nushell](https://www.nushell.sh).

**gl.je** = General Ledger + Journal Entry (the fundamental unit of double-entry bookkeeping)

The ledger is an append-only event stream. State (account balances) is derived by projecting over events.

## Prerequisites

- [xs](https://github.com/cablehead/xs) - event streaming store
- [Nushell](https://www.nushell.sh) - shell with structured data

Install xs nushell integration:
```bash
xs nu --install
```

## Quick Start

```bash
# Terminal 1: Start xs server
xs serve ~/.local/share/gl-demo
```

```nu
# Terminal 2: Nushell session
$env.XS_ADDR = ("~/.local/share/gl-demo" | path expand)
use xs.nu *
use gl.nu *

# Register handlers (once per store)
open handler-validate.nu | .append gl-post.validate.register
open handler-state.nu | .append gl-fact.state.register

# Create accounts
gl activate "Asset:Cash" "asset"
gl activate "Equity:Opening" "equity"

# Post opening balance ($100.00 in cents)
gl post [{account: "Asset:Cash", amount: 10000} {account: "Equity:Opening", amount: -10000}]

# View balances
gl trial-balance
```

## Architecture

```
gl-post (raw input)          gl-fact (canonical)           gl-state (cache)
┌─────────────────┐          ┌─────────────────┐           ┌─────────────────┐
│ {cmd: "post"..} │ ───────► │ {cmd: "post"..} │ ────────► │ {balances: ..}  │
│                 │ validate │ normalized      │ state     │                 │
└─────────────────┘          └─────────────────┘           └─────────────────┘
        │
        │ invalid
        ▼
┌─────────────────┐
│ gl-error        │
│ {error: "..."}  │
└─────────────────┘
```

| Topic | TTL | Purpose |
|-------|-----|---------|
| `gl-post` | forever | Raw input, audit trail |
| `gl-fact` | forever | Canonical, normalized ledger |
| `gl-error` | forever | Validation failures |
| `gl-state` | head:1 | Cached balances (latest only) |

## Event Model (CQRS)

Three commands:

| Command | Description |
|---------|-------------|
| `activate` | Bring an account into existence |
| `deactivate` | Mark account inactive |
| `post` | Balanced transaction (amounts sum to zero) |

Events are stored as xs frames:
```
{cmd: "activate", account: "Asset:Cash", type: "asset"}
{cmd: "post", description: "...", lines: [{account: "...", amount: 10000}, ...]}
```

## Amount Convention

Amounts are **integers in cents** (minor units):

| Display | Stored |
|---------|--------|
| $100.00 | 10000 |
| $45.67 | 4567 |
| -$25.00 | -2500 |

Postings use signed amounts (like ledger-cli):
- Positive = debit
- Negative = credit
- **Sum must equal zero**

## Commands

### Write Commands

```nu
# Activate an account
gl activate "Asset:Cash" "asset"
gl activate "Liability:CreditCard" "liability"
gl activate "Equity:Opening" "equity"
gl activate "Revenue:Sales" "revenue"
gl activate "Expense:Office" "expense"

# Deactivate an account
gl deactivate "Asset:OldAccount"

# Post a balanced transaction
gl post [
  {account: "Asset:Cash", amount: 5000}
  {account: "Revenue:Sales", amount: -5000}
] --description "Invoice #001"
```

### Query Commands

```nu
# View all accounts with balances
gl accounts

# Get balances (O(1) from cache)
gl balances

# Get projected state (accounts + balances records)
gl state

# Trial balance
gl trial-balance

# View raw input stream
gl stream

# View canonical ledger
gl ledger

# View validation errors
gl errors
```

## Example Session

Run the included example script:

```bash
# Start with a fresh store
rm -rf ~/.local/share/gl-demo
xs serve ~/.local/share/gl-demo

# In another terminal
./example.nu
```

> **Note:** The example is not idempotent - it creates accounts and posts transactions. Run against a fresh store each time, or errors will occur (e.g., duplicate account activation).

## Handlers

xs handlers react to frames in real-time. They validate, enrich, or trigger side effects.

### Core Handlers

**handler-validate.nu** - Validates and normalizes input:
```nu
# Register
open handler-validate.nu | .append gl-post.validate.register
```
- Watches `gl-post`
- Normalizes float amounts to integer cents
- Validates postings balance (sum = 0)
- Writes valid entries to `gl-fact`, invalid to `gl-error`

**handler-state.nu** - Maintains balance cache:
```nu
# Register
open handler-state.nu | .append gl-fact.state.register
```
- Watches `gl-fact`
- Updates cached balances on each post
- Writes to `gl-state` with TTL `head:1`

### Handler Architecture

- Handlers **react to** frames (they don't intercept or modify)
- Original frames are **immutable** - handlers append new frames
- Handlers persist across xs restarts
- Errors in handlers unregister them (check `<handler>.unregistered`)

### Available Commands in Handlers

| Command | Description |
|---------|-------------|
| `.cat` | Read frames from stream |
| `.head` | Get latest frame for a topic |
| `.append` | Append new frames |
| `.cas` | Read content by hash |
| `.get` | Retrieve frame by ID |

Note: Handlers don't have `.remove` - use a Command for controlled deletion.

## Why Event Sourcing?

- **Immutable audit trail** - every change is recorded
- **Time travel** - replay to any point in history
- **Simple model** - append-only, no updates or deletes
- **Reactive** - stream changes to subscribers in real-time

## Inspired By

- [ledger-cli](https://ledger-cli.org/) / [hledger](https://hledger.org/) - plain text accounting
- [CQRS](https://martinfowler.com/bliki/CQRS.html) - Command Query Responsibility Segregation
- [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) - storing state as events
