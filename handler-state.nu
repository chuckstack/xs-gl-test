# GL State Handler
#
# Watches gl-fact, maintains cached balance state in gl-state
#
# Register with:
#   open handler-state.nu | .append gl-fact.state.register

{
  run: {|frame|
    # Only process gl-fact topic
    if $frame.topic != "gl-fact" { return }

    let meta = $frame.meta?
    let cmd = $meta.cmd?

    # Get current state (or empty)
    let current = try {
      .head gl-state | get meta
    } catch {
      {balances: {}}
    }

    if $cmd == "activate" {
      # Add account with zero balance
      let new_balances = $current.balances | upsert $meta.account 0
      .append gl-state --meta {balances: $new_balances} --ttl "head:1"
    } else if $cmd == "post" {
      # Update balances
      let new_balances = $meta.lines | reduce --fold $current.balances {|line, bals|
        let current_bal = $bals | get -o $line.account | default 0
        $bals | upsert $line.account ($current_bal + $line.amount)
      }
      .append gl-state --meta {balances: $new_balances} --ttl "head:1"
    }
  }

  resume_from: "tail"
}
