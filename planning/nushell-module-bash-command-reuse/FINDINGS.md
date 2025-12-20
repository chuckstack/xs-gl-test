# Nushell Dual-Mode Script Experiment - Findings

## Objective
Test creating a nushell script that serves as both:
1. An executable script (can be run directly from bash)
2. A nushell module (can be imported and used with subcommands)

**Goal**: Avoid code duplication while supporting both use cases.

## Executive Summary

**SUCCESS**: All three approaches work without code duplication! The core business logic is written once in exported functions, and the `main` function provides CLI routing when executed directly.

**Key Discovery**: Nushell's `main` function is automatically invoked when a script is run directly but is NOT invoked when the script is imported as a module. This natural behavior enables dual-mode operation without any special detection logic.

## Test Results

All three approaches successfully support:
- ✅ Direct execution with shebang: `./script.nu command args`
- ✅ Execution via bash/nu: `nu script.nu command args`
- ✅ Module import: `use script.nu *; command subcommand args`
- ✅ Zero code duplication (business logic written once)

## Approach Comparison

### Approach 1: Main Wrapper (Recommended)
**File**: `approach1-main-wrapper.nu`

**Pattern**:
```nushell
#!/usr/bin/env nu

# Exported commands with namespaces (these work as subcommands when imported)
export def "tool list" [] {
    print "Listing items..."
    ["item1" "item2" "item3"]
}

export def "tool create" [name: string] {
    print $"Creating item: ($name)"
    {name: $name, status: "created"}
}

# Main function for direct execution (routes to exported commands)
def main [subcommand?: string, ...args] {
    if ($subcommand == null) {
        print "Usage: tool <subcommand> [args]"
        return
    }

    match $subcommand {
        "list" => { tool list }
        "create" => { tool create ($args | first) }
        _ => { print $"Unknown subcommand: ($subcommand)" }
    }
}
```

**Pros**:
- Clear separation: exported commands contain logic, main does routing
- Easy to maintain: add a new command by adding export + match case
- Consistent naming: commands keep their namespace in both modes
- Type safety: exported functions have proper parameter types

**Cons**:
- Small amount of routing code in main (but minimal)
- Need to handle argument parsing/validation in main

**Usage**:
```bash
# Direct execution
./approach1-main-wrapper.nu list
./approach1-main-wrapper.nu create myitem

# Module import
use approach1-main-wrapper.nu *
tool list
tool create "myitem"
```

### Approach 2: Conditional Execution
**File**: `approach2-conditional.nu`

**Pattern**:
```nushell
#!/usr/bin/env nu

# Exported commands
export def "bp list" [] {
    [
        {name: "web-app", type: "frontend"}
        {name: "api-server", type: "backend"}
    ]
}

export def "bp create" [name: string, type: string = "general"] {
    {name: $name, type: $type, created: (date now | format date "%Y-%m-%d")}
}

# Main delegates to exported commands
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
            let name = ($rest | first)
            let type = ($rest | get 1? | default "general")
            bp create $name $type
        }
        _ => { print $"Unknown command: ($cmd)" }
    }
}
```

**Pros**:
- Variadic args pattern with `...args`
- Can handle optional parameters naturally
- Clean command structure

**Cons**:
- More complex argument parsing in main
- Need to manually extract and validate args

**Usage**: Same as Approach 1

### Approach 3: Dual Namespace
**File**: `approach3-dual-namespace.nu`

**Pattern**:
```nushell
#!/usr/bin/env nu

# Internal implementation (not exported)
def --env "impl list" [] {
    [
        {id: 1, name: "alpha", status: "active"}
        {id: 2, name: "beta", status: "pending"}
    ]
}

def --env "impl create" [name: string, status: string = "pending"] {
    {id: (random int 100..999), name: $name, status: $status}
}

# Exported commands (thin wrappers)
export def "cmd list" [] {
    print "Current items:"
    impl list
}

export def "cmd create" [name: string, --active] {
    let status = if $active { "active" } else { "pending" }
    print $"Creating: ($name)"
    impl create $name $status
}

# Main routes to exported commands
def main [action?: string, ...args] {
    if ($action == null) {
        print "Usage: cmd <action> [args]"
        return
    }

    match $action {
        "list" => { cmd list }
        "create" => { cmd create ($args | first) }
        _ => { print $"Unknown action: ($action)" }
    }
}
```

**Pros**:
- Clear separation of concerns: `impl` = logic, exported = UI layer
- Exported functions can add formatting/printing
- Internal functions can be reused between exported commands
- Good for complex logic that needs to be composed

**Cons**:
- More layers (impl -> export -> main)
- Slight overhead if logic is simple
- May be overkill for simple scripts

**Usage**: Same as Approach 1

## Key Insights

### 1. The Magic of `main` Function
- Nushell automatically invokes `main` when script is executed directly
- `main` is NOT invoked when script is imported as a module
- This behavior requires NO special detection or environment checking
- Perfect natural boundary between execution modes

### 2. Code Duplication: NONE
- Business logic lives in exported functions (written once)
- `main` function only contains routing logic
- Both modes use the same underlying functions
- Adding a new command requires:
  1. Write the exported function
  2. Add one line to `main` match statement

### 3. Bash Subcommand Style: YES
- All approaches achieve bash-style subcommand behavior
- Example: `./script.nu list`, `./script.nu create item`
- Works identically to tools like `git`, `docker`, etc.

### 4. Namespace Considerations
- Exported commands should use namespaces: `"tool list"`, `"bp create"`
- This prevents naming collisions when importing
- Also provides better organization: `tool list` vs just `list`

### 5. Argument Handling
- Optional args: Use `?` suffix (`subcommand?: string`)
- Variadic args: Use `...args` rest parameter
- Type safety in exported functions, manual parsing in main
- Can use flags in exported commands: `--active`, `--verbose`

## Recommended Approach

**Use Approach 1 (Main Wrapper)** for most cases because:
1. Simplest pattern with clearest structure
2. Easy to understand and maintain
3. Good balance of functionality and complexity
4. Scales well as commands are added

**Use Approach 3 (Dual Namespace)** when:
1. You have complex business logic to isolate
2. Multiple exported commands share internal functions
3. You want a clear separation between logic and presentation
4. You're building a larger tool with reusable components

**Approach 2** is essentially a variant of Approach 1 with different argument handling style.

## Template for New Dual-Mode Scripts

```nushell
#!/usr/bin/env nu

# Exported commands (business logic)
export def "mytool list" [] {
    # Implementation here
    ["item1" "item2" "item3"]
}

export def "mytool create" [name: string, --option] {
    # Implementation here
    {name: $name, created: true}
}

export def "mytool delete" [name: string] {
    # Implementation here
    {name: $name, deleted: true}
}

# Helper for usage display
def show-usage [] {
    print "Usage: mytool <command> [args]"
    print ""
    print "Commands:"
    print "  list              - List all items"
    print "  create <name>     - Create a new item"
    print "  delete <name>     - Delete an item"
}

# Main function for direct execution (routing only)
def main [command?: string, ...args] {
    if ($command == null) {
        show-usage
        return
    }

    match $command {
        "list" => { mytool list }
        "create" => {
            if ($args | is-empty) {
                print "Error: name required"
                return
            }
            mytool create ($args | first)
        }
        "delete" => {
            if ($args | is-empty) {
                print "Error: name required"
                return
            }
            mytool delete ($args | first)
        }
        _ => {
            print $"Unknown command: ($command)"
            show-usage
        }
    }
}
```

## Limitations and Trade-offs

### Minor Limitations
1. **Routing code required**: The `main` function needs a match statement for each command
   - Trade-off: This is minimal boilerplate (~2 lines per command)
   - Benefit: Explicit, clear, and easy to understand

2. **Argument parsing in main**: Some manual parsing needed for complex args
   - Trade-off: Can't directly pass `...args` to typed function parameters
   - Benefit: Full control over argument handling and error messages

3. **Help text duplication**: Usage info in both main and command help
   - Trade-off: Two places to maintain descriptions
   - Benefit: Can provide different detail levels for different contexts

### Not Limitations (Things that work fine)
- ❌ Detection of execution mode (NOT NEEDED - main handles it naturally)
- ❌ Code duplication (NOT AN ISSUE - logic written once)
- ❌ Different behavior between modes (NOT AN ISSUE - same functions called)

## Best Practices

1. **Always use namespaces**: `"tool command"` not just `"command"`
2. **Keep main simple**: Only routing logic, no business logic
3. **Validate in main**: Check required args before calling exported functions
4. **Use type safety**: Let exported functions define proper parameter types
5. **Provide good errors**: Check args in main and give helpful messages
6. **Include usage text**: Make it easy for users to discover commands
7. **Make executable**: `chmod +x script.nu` and include shebang

## Conclusion

**The experiment was a complete success.** Nushell provides excellent support for dual-mode scripts without requiring any special tricks or workarounds. The `main` function's natural behavior creates a perfect boundary between execution modes.

**No code duplication is required.** The business logic lives in exported functions that work identically in both modes. The `main` function only adds minimal routing code.

**Bash-style subcommands work perfectly.** Users can run `./tool.nu list`, `./tool.nu create item`, etc., exactly like familiar CLI tools.

**Recommendation**: Use the Main Wrapper pattern (Approach 1) as the standard pattern for vilara nushell scripts that need dual-mode operation. It's simple, maintainable, and scales well.
