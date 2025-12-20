#!/usr/bin/env nu

# RECOMMENDED PATTERN: Dual-Mode Nushell Script
# This script can be used both as:
#   1. Direct executable: ./RECOMMENDED-PATTERN.nu list
#   2. Importable module: use RECOMMENDED-PATTERN.nu *; demo list

# ============================================================================
# EXPORTED COMMANDS (Business Logic)
# ============================================================================
# These functions contain all the actual logic and are exported so they can
# be used when this script is imported as a module. They use a namespace
# prefix ("demo") to avoid naming conflicts.

# List all demo items
export def "demo list" [] {
    print "Available demo items:"
    [
        {id: 1, name: "alpha", type: "example", active: true}
        {id: 2, name: "beta", type: "sample", active: true}
        {id: 3, name: "gamma", type: "example", active: false}
    ]
}

# Create a new demo item
export def "demo create" [
    name: string          # Name of the item to create
    --type: string = "example"  # Type of item (default: example)
    --active              # Mark the item as active
] {
    let item = {
        id: (random int 100..999)
        name: $name
        type: $type
        active: $active
        created: (date now | format date "%Y-%m-%d %H:%M:%S")
    }

    print $"Created item: ($name)"
    $item
}

# Show details for a specific item
export def "demo info" [name: string] {
    let items = (demo list | select name type active)
    let found = ($items | where name == $name | first | default null)

    if ($found == null) {
        print $"Error: Item '($name)' not found"
        return {error: "not found"}
    }

    print $"Details for: ($name)"
    $found
}

# Delete a demo item (simulated)
export def "demo delete" [name: string, --force] {
    if not $force {
        print $"Would delete: ($name) \(use --force to confirm)"
        return {name: $name, deleted: false}
    }

    print $"Deleted: ($name)"
    {name: $name, deleted: true, timestamp: (date now)}
}

# ============================================================================
# HELPER FUNCTIONS (Not Exported)
# ============================================================================

# Display usage information
def show-usage [] {
    print "Usage: demo <command> [args]"
    print ""
    print "Commands:"
    print "  list                           - List all demo items"
    print "  create <name> [--type TYPE]    - Create a new item"
    print "  info <name>                    - Show item details"
    print "  delete <name> [--force]        - Delete an item"
    print ""
    print "Examples:"
    print "  demo list"
    print "  demo create myitem --type sample --active"
    print "  demo info alpha"
    print "  demo delete beta --force"
}

# ============================================================================
# MAIN FUNCTION (Direct Execution Only)
# ============================================================================
# This function is automatically invoked when the script is run directly
# (e.g., ./script.nu or nu script.nu) but NOT when imported as a module.
# It provides CLI routing to the exported commands.

def main [command?: string, ...args] {
    # No command provided - show usage
    if ($command == null) {
        show-usage
        return
    }

    # Route to appropriate command
    match $command {
        "list" => {
            demo list
        }

        "create" => {
            # Parse required name argument
            if ($args | is-empty) {
                print "Error: create requires a name argument"
                print "Usage: demo create <name> [--type TYPE] [--active]"
                return
            }

            # Extract name and optional flags
            # Note: Flags like --type and --active would need manual parsing here
            # For this example, we'll just pass the name
            let name = ($args | first)
            demo create $name
        }

        "info" => {
            # Parse required name argument
            if ($args | is-empty) {
                print "Error: info requires a name argument"
                print "Usage: demo info <name>"
                return
            }

            demo info ($args | first)
        }

        "delete" => {
            # Parse required name argument
            if ($args | is-empty) {
                print "Error: delete requires a name argument"
                print "Usage: demo delete <name> [--force]"
                return
            }

            demo delete ($args | first)
        }

        _ => {
            print $"Error: Unknown command '($command)'"
            print ""
            show-usage
        }
    }
}

# ============================================================================
# USAGE EXAMPLES
# ============================================================================
#
# DIRECT EXECUTION (via bash or nu):
#   ./RECOMMENDED-PATTERN.nu list
#   ./RECOMMENDED-PATTERN.nu create myitem
#   ./RECOMMENDED-PATTERN.nu info alpha
#   ./RECOMMENDED-PATTERN.nu delete beta
#
# MODULE IMPORT (in nushell):
#   use RECOMMENDED-PATTERN.nu *
#   demo list
#   demo create "myitem" --type "sample" --active
#   demo info "alpha"
#   demo delete "beta" --force
#
# Note: In both modes, the same exported functions are called, ensuring
# consistent behavior. The main function just provides CLI argument routing.
