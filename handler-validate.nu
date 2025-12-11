# GL Validation Handler
#
# Watches gl-post, validates entries, writes to gl-fact or gl-error
#
# Register with:
#   open handler-validate.nu | .append gl-post.validate.register

{
  run: {|frame|
    # Only process gl-post topic
    if $frame.topic != "gl-post" { return }

    let meta = $frame.meta?
    let cmd = $meta.cmd?
    let source_id = $frame.id

    let valid_types = ["asset", "liability", "equity", "revenue", "expense"]

    if $cmd == "activate" {
      let account = $meta.account?
      let type = $meta.type?

      # Validate required fields
      if ($account | is-empty) or ($type | is-empty) {
        .append gl-error --meta {
          source_id: $source_id
          error: "activate requires account and type"
        }
        return
      }

      # Validate account type
      if $type not-in $valid_types {
        .append gl-error --meta {
          source_id: $source_id
          error: $"invalid account type: ($type)"
        }
        return
      }

      # Check for duplicate account
      let balances = try { .head gl-state | get meta.balances } catch { {} }
      if $account in ($balances | columns) {
        .append gl-error --meta {
          source_id: $source_id
          error: $"account already exists: ($account)"
        }
        return
      }

      .append gl-fact --meta {
        cmd: "activate"
        account: $account
        type: $type
        source_id: $source_id
      }
    } else if $cmd == "deactivate" {
      let account = $meta.account?

      # Validate required fields
      if ($account | is-empty) {
        .append gl-error --meta {
          source_id: $source_id
          error: "deactivate requires account"
        }
        return
      }

      # Check account has zero balance
      let balances = try { .head gl-state | get meta.balances } catch { {} }
      let balance = $balances | get -o $account | default 0
      if $balance != 0 {
        .append gl-error --meta {
          source_id: $source_id
          error: $"cannot deactivate account with non-zero balance: ($account) has ($balance)"
        }
        return
      }

      .append gl-fact --meta {
        cmd: "deactivate"
        account: $account
        source_id: $source_id
      }
    } else if $cmd == "post" {
      let lines = $meta.lines?
      let description = $meta.description? | default ""

      # Validate required fields
      if ($lines | is-empty) {
        .append gl-error --meta {
          source_id: $source_id
          error: "post requires lines"
        }
        return
      }

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

      .append gl-fact --meta {
        cmd: "post"
        description: $description
        lines: $normalized_lines
        source_id: $source_id
      }
    }
  }

  # Resume from last processed frame, otherwise from start
  resume_from: (.head gl-fact | if ($in | is-not-empty) { get meta.frame_id } else { "root" })
}
