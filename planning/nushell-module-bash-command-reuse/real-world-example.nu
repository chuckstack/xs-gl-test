#!/usr/bin/env nu

# Real-world example: A blueprint management tool
# This demonstrates a practical dual-mode script for managing project blueprints

# ============================================================================
# EXPORTED COMMANDS
# ============================================================================

# List all available blueprints
export def "bp list" [
    --type: string     # Filter by type (frontend, backend, fullstack)
    --active           # Show only active blueprints
] {
    let blueprints = [
        {name: "react-app", type: "frontend", active: true, version: "1.2.0"}
        {name: "vue-spa", type: "frontend", active: true, version: "2.0.1"}
        {name: "django-api", type: "backend", active: true, version: "3.1.4"}
        {name: "flask-minimal", type: "backend", active: false, version: "1.0.0"}
        {name: "mern-stack", type: "fullstack", active: true, version: "4.2.0"}
        {name: "lamp-classic", type: "fullstack", active: false, version: "0.9.1"}
    ]

    mut filtered = $blueprints

    if ($type != null) {
        $filtered = ($filtered | where type == $type)
    }

    if $active {
        $filtered = ($filtered | where active == true)
    }

    print "Available Blueprints:"
    $filtered
}

# Create a new project from a blueprint
export def "bp create" [
    name: string           # Project name
    template: string       # Blueprint template to use
    --output: string       # Output directory (default: ./name)
] {
    let output_dir = if ($output != null) { $output } else { $"./($name)" }

    print $"Creating project '($name)' from template '($template)'"
    print $"Output directory: ($output_dir)"

    {
        project: $name
        template: $template
        output: $output_dir
        status: "created"
        timestamp: (date now | format date "%Y-%m-%d %H:%M:%S")
    }
}

# Show detailed information about a blueprint
export def "bp info" [template: string] {
    let blueprints = {
        "react-app": {
            name: "react-app"
            type: "frontend"
            description: "Modern React application with TypeScript and Vite"
            features: ["TypeScript", "Vite", "React Router", "TailwindCSS"]
            version: "1.2.0"
        }
        "django-api": {
            name: "django-api"
            type: "backend"
            description: "Django REST API with authentication"
            features: ["Django", "DRF", "JWT Auth", "PostgreSQL"]
            version: "3.1.4"
        }
        "mern-stack": {
            name: "mern-stack"
            type: "fullstack"
            description: "Full MERN stack application"
            features: ["MongoDB", "Express", "React", "Node.js"]
            version: "4.2.0"
        }
    }

    let info = ($blueprints | get $template | default null)

    if ($info == null) {
        print $"Error: Blueprint '($template)' not found"
        return {error: "not found"}
    }

    print $"Blueprint: ($template)"
    $info
}

# Update a blueprint to the latest version
export def "bp update" [template: string, --force] {
    print $"Checking for updates: ($template)"

    let current_version = "1.2.0"
    let latest_version = "1.3.0"

    if ($current_version == $latest_version) {
        print "Already up to date!"
        return {status: "current", version: $current_version}
    }

    if $force {
        print $"Updating from ($current_version) to ($latest_version)..."
        return {
            status: "updated"
            old_version: $current_version
            new_version: $latest_version
        }
    } else {
        print $"Update available: ($current_version) -> ($latest_version)"
        print "Run with --force to update"
        return {status: "available", version: $latest_version}
    }
}

# Validate a blueprint configuration
export def "bp validate" [path: string] {
    print $"Validating blueprint at: ($path)"

    # Simulate validation checks
    let checks = [
        {check: "Structure", status: "pass"}
        {check: "Dependencies", status: "pass"}
        {check: "Configuration", status: "pass"}
        {check: "Templates", status: "pass"}
    ]

    print "Validation Results:"
    $checks

    {
        path: $path
        valid: true
        checks: ($checks | length)
        passed: ($checks | where status == "pass" | length)
    }
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def show-usage [] {
    print "Blueprint Management Tool"
    print ""
    print "Usage: bp <command> [options]"
    print ""
    print "Commands:"
    print "  list [--type TYPE] [--active]      - List available blueprints"
    print "  create <name> <template> [--output DIR] - Create project from blueprint"
    print "  info <template>                    - Show blueprint details"
    print "  update <template> [--force]        - Update blueprint to latest version"
    print "  validate <path>                    - Validate blueprint configuration"
    print ""
    print "Examples:"
    print "  bp list --type frontend --active"
    print "  bp create myapp react-app --output ~/projects/myapp"
    print "  bp info django-api"
    print "  bp update react-app --force"
    print "  bp validate ./my-blueprint"
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

def main [command?: string, ...args] {
    if ($command == null) {
        show-usage
        return
    }

    match $command {
        "list" => {
            bp list
        }

        "create" => {
            if ($args | length) < 2 {
                print "Error: create requires <name> and <template> arguments"
                print "Usage: bp create <name> <template> [--output DIR]"
                return
            }

            let name = ($args | first)
            let template = ($args | get 1)
            bp create $name $template
        }

        "info" => {
            if ($args | is-empty) {
                print "Error: info requires <template> argument"
                print "Usage: bp info <template>"
                return
            }

            bp info ($args | first)
        }

        "update" => {
            if ($args | is-empty) {
                print "Error: update requires <template> argument"
                print "Usage: bp update <template> [--force]"
                return
            }

            bp update ($args | first)
        }

        "validate" => {
            if ($args | is-empty) {
                print "Error: validate requires <path> argument"
                print "Usage: bp validate <path>"
                return
            }

            bp validate ($args | first)
        }

        _ => {
            print $"Error: Unknown command '($command)'"
            print ""
            show-usage
        }
    }
}
