#!/usr/bin/env nu

# Approach 2: Conditional execution based on environment
# Attempts to detect if being imported vs executed

# Export individual commands
export def "bp list" [] {
    print "Blueprint list:"
    [
        {name: "web-app", type: "frontend"}
        {name: "api-server", type: "backend"}
        {name: "database", type: "storage"}
    ]
}

export def "bp create" [name: string, type: string = "general"] {
    print $"Creating blueprint: ($name) \(($type))"
    {name: $name, type: $type, created: (date now | format date "%Y-%m-%d")}
}

export def "bp info" [name: string] {
    print $"Blueprint info for: ($name)"
    {
        name: $name
        description: $"Details about ($name)"
        version: "1.0.0"
    }
}

# Helper to show usage
def show-usage [] {
    print "Usage: bp <command> [args]"
    print ""
    print "Commands:"
    print "  list                    - List all blueprints"
    print "  create <name> [type]    - Create a new blueprint"
    print "  info <name>             - Show blueprint info"
}

# Main function for direct execution
def main [...args] {
    if ($args | is-empty) {
        show-usage
        return
    }

    let cmd = ($args | first)

    match $cmd {
        "list" => { bp list }
        "create" => {
            let rest = ($args | skip 1)
            if ($rest | length) == 0 {
                print "Error: create requires a name"
                return
            }
            let name = ($rest | first)
            let type = ($rest | get 1? | default "general")
            bp create $name $type
        }
        "info" => {
            let rest = ($args | skip 1)
            if ($rest | length) == 0 {
                print "Error: info requires a name"
                return
            }
            bp info ($rest | first)
        }
        _ => {
            print $"Unknown command: ($cmd)"
            show-usage
        }
    }
}
