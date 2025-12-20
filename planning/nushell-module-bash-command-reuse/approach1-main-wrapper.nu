#!/usr/bin/env nu

# Approach 1: Main wrapper function that delegates to exported commands
# This approach uses a main function to handle direct execution

# Export individual commands that work as subcommands
export def "tool list" [] {
    print "Listing items..."
    ["item1" "item2" "item3"]
}

export def "tool create" [name: string] {
    print $"Creating item: ($name)"
    {name: $name, status: "created", timestamp: (date now)}
}

export def "tool delete" [name: string] {
    print $"Deleting item: ($name)"
    {name: $name, status: "deleted"}
}

# Main function for direct execution
def main [subcommand?: string, ...args] {
    if ($subcommand == null) {
        print "Usage: tool <subcommand> [args]"
        print "Subcommands:"
        print "  list              - List all items"
        print "  create <name>     - Create a new item"
        print "  delete <name>     - Delete an item"
        return
    }

    match $subcommand {
        "list" => { tool list }
        "create" => {
            if ($args | length) == 0 {
                print "Error: create requires a name argument"
                return
            }
            tool create ($args | first)
        }
        "delete" => {
            if ($args | length) == 0 {
                print "Error: delete requires a name argument"
                return
            }
            tool delete ($args | first)
        }
        _ => { print $"Unknown subcommand: ($subcommand)" }
    }
}
