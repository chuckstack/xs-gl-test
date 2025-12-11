# GL Example Session
#
# Run with:
#   source example.nu

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

# Check balances
gl accounts
