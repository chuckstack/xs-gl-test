# GL State Handler
#
# Watches gl-fact, maintains cached balance state in gl-state
#
# Register with:
#   open handler-state.nu | .append gl-fact.state.register

{
  run: {|frame|
    let meta = $frame.meta?
    let cmd = $meta.cmd?

    if $cmd == "post" {
      # Get current state (or empty)
      let current = try {
        .head gl-state | get meta
      } catch {
        {balances: {}}
      }

      # Update balances
      let new_balances = $meta.lines | reduce --fold $current.balances {|line, bals|
        let current_bal = $bals | get -o $line.account | default 0
        $bals | upsert $line.account ($current_bal + $line.amount)
      }

      # Write new state with TTL head:1 (only keep latest)
      .append gl-state --meta {balances: $new_balances} --ttl "head:1"
    }

    # TODO: handle activate/deactivate for accounts state
  }

  resume_from: "tail"
}
