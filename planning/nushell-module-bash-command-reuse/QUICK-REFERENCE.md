# Quick Reference: Dual-Mode Nushell Scripts

## TL;DR

You CAN create nushell scripts that work both as executables and importable modules WITHOUT code duplication!

**Key Discovery**: Nushell's `main` function is automatically invoked when executed directly but NOT when imported. This enables dual-mode operation naturally.

## Pattern (Copy This)

```nushell
#!/usr/bin/env nu

# 1. EXPORTED COMMANDS (write your logic here)
export def "tool list" [] {
    ["item1" "item2" "item3"]
}

export def "tool create" [name: string] {
    {name: $name, status: "created"}
}

# 2. MAIN FUNCTION (routing only - called when executed directly)
def main [command?: string, ...args] {
    if ($command == null) {
        print "Usage: tool <command> [args]"
        return
    }

    match $command {
        "list" => { tool list }
        "create" => { tool create ($args | first) }
        _ => { print "Unknown command" }
    }
}
```

## How It Works

### Direct Execution
```bash
./tool.nu list          # Calls main, which calls "tool list"
./tool.nu create foo    # Calls main, which calls "tool create"
```

### Module Import
```nushell
use tool.nu *
tool list              # Calls "tool list" directly (main not invoked)
tool create "foo"      # Calls "tool create" directly
```

## The Magic

1. **Write logic once** in exported functions
2. **main provides CLI routing** when executed directly
3. **No code duplication** - both modes use same functions
4. **No special detection** - nushell handles it automatically

## Usage Examples

See these files in the experiment directory:
- `RECOMMENDED-PATTERN.nu` - Fully documented example
- `approach1-main-wrapper.nu` - Simple example
- `approach2-conditional.nu` - Alternative style
- `approach3-dual-namespace.nu` - Advanced pattern

## Testing Both Modes

```bash
# Test direct execution
./RECOMMENDED-PATTERN.nu list
./RECOMMENDED-PATTERN.nu create test

# Test module import
nu -c "use RECOMMENDED-PATTERN.nu *; demo list"
```

## Zero Trade-offs

- ✅ No code duplication
- ✅ Bash-style subcommands work perfectly
- ✅ Module imports work naturally
- ✅ Type safety preserved in exported functions
- ✅ Minimal boilerplate (only routing in main)

## When to Use This Pattern

Use dual-mode scripts when:
- You want a tool that can be both CLI and library
- You're building reusable utilities
- You want bash-style subcommand behavior
- You want to avoid maintaining separate CLI and module code

## Complete Working Example

See `/tmp/nu-command-experiment/RECOMMENDED-PATTERN.nu` for a production-ready template with:
- Multiple commands with flags
- Error handling
- Usage help
- Comments explaining each section
- Examples of both usage modes
