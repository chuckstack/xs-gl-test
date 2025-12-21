#!/usr/bin/env nu
# gl.je CLI - thin HTTP client to http-nu server
#
# Usage:
#   Executable: ./gl-cli.nu account activate cash asset
#   Module:     use gl-cli.nu *; gl account activate cash asset

# ─────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────

def gl-server [] {
  $env | get -o GL_SERVER | default "http://localhost:3001"
}

# ─────────────────────────────────────────────────────────────
# HTTP helpers
# ─────────────────────────────────────────────────────────────

def gl-get [path: string] {
  http get $"(gl-server)($path)" --headers [Accept application/json]
}

def gl-post [path: string, body: record] {
  $body | to json | http post $"(gl-server)($path)" --content-type application/json --headers [Accept application/json]
}

# ─────────────────────────────────────────────────────────────
# EXPORTED COMMANDS
# ─────────────────────────────────────────────────────────────

# List all active accounts
export def "gl account list" [] {
  gl-get "/accounts"
}

# Activate an account
export def "gl account activate" [
  name: string   # Account identifier (e.g. cash, travel)
  type: string   # Account type: asset, liability, equity, revenue, expense
] {
  gl-post "/account/activate" {name: $name, type: $type}
}

# Deactivate an account
export def "gl account deactivate" [
  name: string   # Account identifier
] {
  gl-post "/account/deactivate" {name: $name}
}

# ─────────────────────────────────────────────────────────────
# CLI ROUTING (only runs when executed directly)
# ─────────────────────────────────────────────────────────────

def show-usage [] {
  print "gl.je CLI"
  print ""
  print "Usage: gl <command> [args]"
  print ""
  print "Commands:"
  print "  account list                    List all active accounts"
  print "  account activate <name> <type>  Activate an account"
  print "  account deactivate <name>       Deactivate an account"
  print ""
  print "Environment:"
  print "  GL_SERVER  Server URL (default: http://localhost:3001)"
}

def main [command?: string, ...args] {
  if $command == null {
    show-usage
    return
  }

  match $command {
    "account" => {
      if ($args | is-empty) {
        print "Usage: gl account <list|activate|deactivate> [args]"
        return
      }
      let subcommand = $args | first
      let rest = $args | skip 1

      match $subcommand {
        "list" => { gl account list }
        "activate" => {
          if ($rest | length) < 2 {
            print "Usage: gl account activate <name> <type>"
            return
          }
          gl account activate ($rest | get 0) ($rest | get 1)
        }
        "deactivate" => {
          if ($rest | is-empty) {
            print "Usage: gl account deactivate <name>"
            return
          }
          gl account deactivate ($rest | first)
        }
        _ => { print $"Unknown subcommand: ($subcommand)" }
      }
    }
    _ => {
      print $"Unknown command: ($command)"
      show-usage
    }
  }
}
