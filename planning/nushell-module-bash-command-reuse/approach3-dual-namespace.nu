#!/usr/bin/env nu

# Approach 3: Dual namespace - internal and exported
# Internal commands do the work, exported commands are thin wrappers

# Internal implementation (not exported)
def --env "impl list" [] {
    [
        {id: 1, name: "alpha", status: "active"}
        {id: 2, name: "beta", status: "pending"}
        {id: 3, name: "gamma", status: "active"}
    ]
}

def --env "impl create" [name: string, status: string = "pending"] {
    {
        id: (random int 100..999)
        name: $name
        status: $status
        created: (date now | format date "%Y-%m-%d %H:%M:%S")
    }
}

def --env "impl status" [name: string] {
    let items = (impl list)
    $items | where name == $name | first | default {error: "not found"}
}

# Exported commands that use internal implementation
export def "cmd list" [] {
    print "Current items:"
    impl list
}

export def "cmd create" [name: string, --active] {
    let status = if $active { "active" } else { "pending" }
    print $"Creating: ($name)"
    impl create $name $status
}

export def "cmd status" [name: string] {
    print $"Status for: ($name)"
    impl status $name
}

# Main for direct execution
def main [action?: string, ...args] {
    if ($action == null) {
        print "Usage: cmd <action> [args]"
        print ""
        print "Actions:"
        print "  list              - List all items"
        print "  create <name>     - Create new item"
        print "  status <name>     - Check item status"
        return
    }

    match $action {
        "list" => { cmd list }
        "create" => {
            if ($args | is-empty) {
                print "Error: name required"
                return
            }
            cmd create ($args | first)
        }
        "status" => {
            if ($args | is-empty) {
                print "Error: name required"
                return
            }
            cmd status ($args | first)
        }
        _ => { print $"Unknown action: ($action)" }
    }
}
