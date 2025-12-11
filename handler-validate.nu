# GL Validation Handler
#
# Watches gl-post, validates entries, writes to gl-fact or gl-error
#
# Register with:
#   open handler-validate.nu | .register gl-post.validate

{
  run: {|frame|
    let meta = $frame.meta?
    let cmd = $meta.cmd?
    let source_id = $frame.id

    if $cmd == "post" {
      let lines = $meta.lines?
      let description = $meta.description? | default ""

      # Normalize: convert float amounts to integer cents
      let normalized_lines = $lines | each {|line|
        let amount = $line.amount
        let cents = if ($amount | describe) == "float" {
          ($amount * 100) | math round | into int
        } else {
          $amount
        }
        {account: $line.account, amount: $cents}
      }

      # Validate: lines must sum to zero
      let total = $normalized_lines | get amount | math sum
      if $total != 0 {
        .append gl-error --meta {
          source_id: $source_id
          error: $"posting does not balance: sum = ($total)"
        }
        return
      }

      # Valid - promote to gl-fact
      .append gl-fact --meta {
        cmd: "post"
        description: $description
        lines: $normalized_lines
        source_id: $source_id
      }
    }

    # TODO: validate activate (check valid account types)
    # TODO: validate deactivate
  }

  resume_from: "tail"
}
