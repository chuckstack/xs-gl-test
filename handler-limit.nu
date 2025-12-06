# Simple handler: error if any line amount > $100 (10000 cents)
#
# Register with:
#   open handler-limit.nu | .append gl-limit.register
#
# Unregister with:
#   .append gl-limit.unregister

{
  run: {|frame|
    # Only check post commands
    if $frame.meta?.cmd? != "post" { return }

    # Check if any amount exceeds $100 (10000 cents)
    let large = $frame.meta.lines | where { ($in.amount | math abs) > 10000 }

    if ($large | length) > 0 {
      .append gl.error --meta {
        ref: $frame.id
        error: "amount exceeds $100 limit"
        amounts: ($large | get amount)
      }
    }
  }

  resume_from: "tail"
}
