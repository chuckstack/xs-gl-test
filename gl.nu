# General Ledger - Event Sourced Accounting
# Commands: activate, deactivate, post
# Amounts in cents (integer minor units)

# ─────────────────────────────────────────────────────────────
# COMMANDS
# ─────────────────────────────────────────────────────────────

# Activate an account
export def "gl activate" [
    account: string  # e.g., "Asset:Cash"
    type: string     # asset, liability, equity, revenue, expense
] {
    .append gl-post --meta {cmd: "activate", account: $account, type: $type}
}

# Deactivate an account
export def "gl deactivate" [account: string] {
    .append gl-post --meta {cmd: "deactivate", account: $account}
}

# Post a transaction (amounts in cents or dollars, must sum to zero)
# Validation and normalization handled by handler-validate
export def "gl post" [
    lines: list           # [{account: "Asset:Cash", amount: 10000}, ...]
    --description: string # optional description
] {
    .append gl-post --meta {
        cmd: "post"
        description: ($description | default "")
        lines: $lines
    }
}

# ─────────────────────────────────────────────────────────────
# QUERIES
# ─────────────────────────────────────────────────────────────

# Get balances from cache, fallback to projection
export def "gl balances" [] {
    try {
        .head gl-state | get meta.balances
    } catch {
        gl state | get balances
    }
}

# Project state from gl-fact (canonical ledger)
export def "gl state" [] {
    .cat gl-fact | reduce --fold {accounts: {}, balances: {}} {|frame, state|
        let cmd = $frame.meta.cmd
        if $cmd == "activate" {
            let new_accounts = $state.accounts | insert $frame.meta.account $frame.meta.type
            {accounts: $new_accounts, balances: $state.balances}
        } else if $cmd == "deactivate" {
            let new_accounts = $state.accounts | upsert $frame.meta.account "inactive"
            {accounts: $new_accounts, balances: $state.balances}
        } else if $cmd == "post" {
            let new_balances = $frame.meta.lines | reduce --fold $state.balances {|line, bals|
                let current = $bals | get -o $line.account | default 0
                $bals | upsert $line.account ($current + $line.amount)
            }
            {accounts: $state.accounts, balances: $new_balances}
        } else {
            $state
        }
    }
}

# List accounts with balances
export def "gl accounts" [] {
    let s = gl state
    $s.accounts | transpose account type | each {|row|
        let bal = $s.balances | get -o $row.account | default 0
        {
            account: $row.account
            type: $row.type
            balance: $bal
            display: ($bal / 100 | into string --decimals 2)
        }
    } | sort-by type account
}

# Trial balance
export def "gl trial-balance" [] {
    gl accounts | select account type balance display
}

# View raw input stream
export def "gl stream" [] {
    .cat gl-post
}

# View canonical ledger
export def "gl ledger" [] {
    .cat gl-fact
}

# View validation errors
export def "gl errors" [] {
    .cat gl-error
}
