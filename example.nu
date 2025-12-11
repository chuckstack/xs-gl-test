#!/usr/bin/env nu
# GL Example Session
#
# Run with:
#   ./example.nu

$env.XS_ADDR = ("~/.local/share/gl-demo" | path expand)
use xs.nu *
use gl.nu *

# Register handlers
open handler-validate.nu | .append gl-post.validate.register
open handler-state.nu | .append gl-fact.state.register

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

# Allow handlers to complete
sleep 500ms

# Check balances
gl accounts

# ─────────────────────────────────────────────────────────────
# ERROR CASES
# ─────────────────────────────────────────────────────────────

print "\n--- Error cases ---"

# Unbalanced posting
gl post [{account: "Asset:Cash", amount: 1000}] --description "Unbalanced"

# Duplicate account activation
gl activate "Asset:Cash" "asset"

# Invalid account type
gl activate "Asset:Inventory" "assett"

# Deactivate account with non-zero balance
gl deactivate "Asset:Bank"

sleep 500ms

# Show errors
print "\nValidation errors:"
gl errors | each { $in.meta } | select source_id error
