# gl - Event-Sourced General Ledger

A minimal double-entry accounting system built on [xs](https://github.com/cablehead/xs) (cross.stream) and [Nushell](https://www.nushell.sh).

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

# Create accounts
gl activate "Asset:Cash" "asset"
gl activate "Equity:Opening" "equity"

# Post opening balance ($100.00 in cents)
gl post [{account: "Asset:Cash", amount: 10000} {account: "Equity:Opening", amount: -10000}]

# View balances
gl accounts
```

## Event Model (CQRS)

Single stream, three commands:

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

# Get projected state (accounts + balances records)
gl state

# Trial balance
gl trial-balance

# View raw event stream
gl stream
```

## Example Session

```nu
# Set up accounts
gl activate "Asset:Cash" "asset"
gl activate "Asset:Bank" "asset"
gl activate "Equity:Opening" "equity"
gl activate "Revenue:Sales" "revenue"
gl activate "Expense:Rent" "expense"

# Opening balance
gl post [{account: "Asset:Bank", amount: 100000} {account: "Equity:Opening", amount: -100000}] --description "Opening balance"

# Receive payment
gl post [{account: "Asset:Cash", amount: 5000} {account: "Revenue:Sales", amount: -5000}] --description "Cash sale"

# Pay rent
gl post [{account: "Expense:Rent", amount: 20000} {account: "Asset:Bank", amount: -20000}] --description "Monthly rent"

# Transfer cash to bank
gl post [{account: "Asset:Bank", amount: 5000} {account: "Asset:Cash", amount: -5000}] --description "Deposit"

# Check balances
gl accounts
```

## Handlers

xs handlers react to frames in real-time. They can validate, enrich, or trigger side effects.

### Example: Amount Limit Handler

`handler-limit.nu` appends an error frame when any posting line exceeds $100:

```nu
# Register the handler
open handler-limit.nu | .append gl-limit.register

# Check it's active
.cat -T gl-limit.active

# Unregister when done
.append gl-limit.unregister
```

When a posting exceeds the limit:
```nu
# This triggers an error (15000 = $150)
gl post [{account: "Expense:Office", amount: 15000} {account: "Asset:Cash", amount: -15000}]

# View errors
.cat -T gl.error
```

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
