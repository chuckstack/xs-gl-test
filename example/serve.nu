# gl.je server - http-nu handler for accounts
# Run with: cat serve.nu | http-nu :3001 -
#
# Requires xs server running: xs serve ~/.local/share/gl-demo

use http-nu/router *
use http-nu/datastar *
use http-nu/html *

# xs integration - these run inside http-nu's nushell context
def xs-addr [] { $env.XS_ADDR }

def xs-append [topic: string, --meta: record] {
  xs append (xs-addr) $topic --meta ($meta | to json -r) | from json
}

def xs-cat [--topic: string, --follow, --last-id: string] {
  let params = [
    (if $topic != null { ["--topic" $topic] })
    (if $follow { "--follow" })
    (if $last_id != null { ["--last-id" $last_id] })
  ] | compact | flatten
  xs cat (xs-addr) ...$params | lines | each { from json }
}

def xs-head [topic: string] {
  try { xs head (xs-addr) $topic | from json } catch { null }
}

# Account operations
def account-activate [name: string, type: string] {
  xs-append gl-account --meta {cmd: "activate", account: $name, type: $type}
}

def account-deactivate [name: string] {
  xs-append gl-account --meta {cmd: "deactivate", account: $name}
}

def account-list [] {
  xs-cat --topic gl-account
  | reduce --fold {} {|frame, acc|
    let meta = $frame.meta
    if $meta.cmd == "activate" {
      $acc | upsert $meta.account {name: $meta.account, type: $meta.type, active: true}
    } else if $meta.cmd == "deactivate" {
      $acc | upsert $meta.account {name: $meta.account, type: ($acc | get -o $meta.account | get -o type | default "unknown"), active: false}
    } else {
      $acc
    }
  }
  | values
  | where active == true
  | select name type
}

# Detect if request is from CLI (Accept: application/json) or web
def is-cli [req: record] {
  let accept = $req.headers | get -o accept | default ""
  $accept | str contains "application/json"
}

{|req|
  # Capture body before any other statements (nushell pipeline semantics)
  let body = $in

  # Set XS_ADDR for this request context
  $env.XS_ADDR = ($env | get -o XS_ADDR | default ("~/.local/share/gl-demo" | path expand))

  $body | dispatch $req [
    # ─────────────────────────────────────────────────────────────
    # WEB: Index page with Datastar
    # ─────────────────────────────────────────────────────────────
    (
      route {method: GET, path: "/"} {|req ctx|
        _html {
          _head {
            _meta {charset: "UTF-8"}
            | +title "gl.je - Accounts"
            | +script {type: "module", src: $DATASTAR_CDN_URL}
          }
          | +body {"data-signals": "{}"} {
            _h1 "gl.je Accounts"
            | +div {id: "accounts", "data-on:load": "@get('/accounts')"} "Loading..."
            | +hr
            | +h3 "Activate Account"
            | +form {"data-on:submit__prevent": "@post('/account/activate')"} {
              _input {type: "text", "data-bind": "name", placeholder: "name (e.g. cash)"}
              | +select {"data-bind": "type"} {
                _option {value: "asset"} "asset"
                | +option {value: "liability"} "liability"
                | +option {value: "equity"} "equity"
                | +option {value: "revenue"} "revenue"
                | +option {value: "expense"} "expense"
              }
              | +button {type: "submit"} "Activate"
            }
          }
        }
      }
    )

    # ─────────────────────────────────────────────────────────────
    # ACCOUNT LIST - serves both CLI and web
    # ─────────────────────────────────────────────────────────────
    (
      route {method: GET, path: "/accounts"} {|req ctx|
        let accounts = account-list

        if (is-cli $req) {
          # CLI: return JSON
          $accounts
        } else {
          # Web: return Datastar SSE patch
          _div {id: "accounts"} {
            if ($accounts | is-empty) {
              _p "No accounts yet."
            } else {
              _table {
                _tr { _th "Name" | +th "Type" }
                | str join
                | $in + ($accounts | each {|a|
                  _tr { _td $a.name | +td $a.type }
                } | str join)
              }
            }
          } | to dstar-patch-element | to sse
        }
      }
    )

    # ─────────────────────────────────────────────────────────────
    # ACCOUNT ACTIVATE - serves both CLI and web
    # ─────────────────────────────────────────────────────────────
    (
      route {method: POST, path: "/account/activate"} {|req ctx|
        # from datastar-request handles $in internally - works for both CLI JSON and Datastar
        let input = from datastar-request $req

        let name = $input.name
        let type = $input.type

        # Activate account
        let frame = account-activate $name $type

        if (is-cli $req) {
          # CLI: return the frame
          $frame
        } else {
          # Web: refresh the accounts list
          let accounts = account-list
          _div {id: "accounts"} {
            _table {
              _tr { _th "Name" | +th "Type" }
              | str join
              | $in + ($accounts | each {|a|
                _tr { _td $a.name | +td $a.type }
              } | str join)
            }
          } | to dstar-patch-element | to sse
        }
      }
    )

    # ─────────────────────────────────────────────────────────────
    # ACCOUNT DEACTIVATE - serves both CLI and web
    # ─────────────────────────────────────────────────────────────
    (
      route {method: POST, path: "/account/deactivate"} {|req ctx|
        # from datastar-request handles $in internally
        let input = from datastar-request $req

        let name = $input.name
        let frame = account-deactivate $name

        if (is-cli $req) {
          $frame
        } else {
          let accounts = account-list
          _div {id: "accounts"} {
            _table {
              _tr { _th "Name" | +th "Type" }
              | str join
              | $in + ($accounts | each {|a|
                _tr { _td $a.name | +td $a.type }
              } | str join)
            }
          } | to dstar-patch-element | to sse
        }
      }
    )
  ]
}
