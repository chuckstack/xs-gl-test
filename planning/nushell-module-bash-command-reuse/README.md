# Nushell Module and Bash Command Reuse

## TOC

- [Summary](#summary)
- [Key Discovery](#key-discovery)
- [The Pattern](#the-pattern)
- [Validation Results](#validation-results)
- [Recommendations for Vilara](#recommendations-for-vilara)
- [Supporting Artifacts](#supporting-artifacts)
- [Next Steps](#next-steps)

## Summary

The purpose of this document is to describe the pattern for creating nushell scripts that function as both executable bash commands and importable nushell modules without code duplication.

This is important because it enables vilara to create tools that work seamlessly in both CLI and library contexts, reducing maintenance burden and providing consistent behavior across different use cases.

## Key Discovery

**Nushell's `main` function provides natural dual-mode support:**
- Automatically invoked when script is executed directly (e.g., `./script.nu command`)
- Never invoked when script is imported as a module (e.g., `use script.nu`)
- No special detection or environment checking required

This natural behavior creates a perfect boundary for dual-mode operation.

## The Pattern

**Core principle:** Write business logic once in exported functions, use `main` for CLI routing.

```nushell
#!/usr/bin/env nu

# Business logic (written once)
export def "tool list" [] {
    ["item1" "item2" "item3"]
}

export def "tool create" [name: string, --active] {
    {name: $name, active: $active}
}

# CLI routing (only runs when executed directly)
def main [command?: string, ...args] {
    match $command {
        "list" => { tool list }
        "create" => { tool create ($args | first) }
        _ => { print "Usage: tool <command> [args]" }
    }
}
```

**How it works:**
1. Export commands with namespace prefixes (e.g., `"tool list"`, `"bp create"`)
2. Implement all logic in these exported functions
3. Use `main` function to route CLI arguments to exported functions
4. Same functions called in both modes - zero duplication

**Bash subcommand support:**
Yes, fully achievable through `main` function argument handling. Scripts work like familiar CLI tools (`git`, `docker`, etc.):
```bash
./script.nu list
./script.nu create myitem --active
```

**Module import support:**
```nushell
use script.nu *
tool list
tool create "myitem" --active
```

## Validation Results

All tests passed successfully:
- Direct execution via bash: ✓
- Direct execution via nu: ✓
- Module import and usage: ✓
- Bash-style subcommands: ✓
- Flags and options: ✓
- Error handling: ✓
- Type safety: ✓

**Three approaches tested:**
1. **Main Wrapper** (recommended) - Simple routing in main, logic in exports
2. **Conditional Execution** - Alternative argument parsing style
3. **Dual Namespace** - Advanced pattern with internal/external functions

All approaches work without code duplication or special detection logic.

## Recommendations for Vilara

**Adopt the Main Wrapper pattern** for vilara nushell modules that need both CLI and library functionality:

1. **Use namespace prefixes** for all exported commands to prevent naming conflicts
2. **Keep main simple** - only routing logic, no business logic
3. **Validate in main** - check required arguments before calling exported functions
4. **Provide good errors** - helpful messages for missing/invalid arguments
5. **Include usage text** - make commands discoverable

**Benefits for vilara:**
- Tools work as both CLI and library without duplication
- Standard bash-style command interfaces for familiarity
- Reusable components across the framework
- Consistent behavior in both modes
- Minimal maintenance overhead

**When to use:**
- Creating framework utilities (like `bp` for blueprint management)
- Building tools that need both scripting and interactive use
- Developing commands that should be composable in pipelines

**Template location:**
See `./planning/nushell-module-bash-command-reuse/RECOMMENDED-PATTERN.nu` for a production-ready template.

## Supporting Artifacts

The experiment created comprehensive documentation and working examples in:
`./planning/nushell-module-bash-command-reuse/`

**Start here:**
- `QUICK-REFERENCE.md` - Quick copy-paste pattern (2 min read)
- `RECOMMENDED-PATTERN.nu` - Production template to copy and adapt
- `FINDINGS.md` - Comprehensive 11KB analysis

**Working examples:**
- `real-world-example.nu` - Blueprint manager tool (realistic use case)
- `approach1-main-wrapper.nu` - Simple pattern (recommended)
- `approach2-conditional.nu` - Alternative argument handling
- `approach3-dual-namespace.nu` - Advanced pattern with internal/external split

**Testing:**
- `comprehensive-test.nu` - Full validation suite
- `test-runner.nu` - Automated testing
- `test-module-import.nu` - Module import tests

**Run tests:**
```bash
cd planning/nushell-module-bash-command-reuse
nu -l -c "source comprehensive-test.nu"
```

## Next Steps

1. **Review template**: Study `RECOMMENDED-PATTERN.nu` for implementation details
2. **Consider adoption**: Identify vilara modules that would benefit from this pattern
3. **Update standards**: Consider adding this pattern to `core/modules/MODULE_DEVELOPMENT.md`
4. **Create examples**: Refactor existing vilara tools as proof-of-concept

**No trade-offs or limitations found** - the pattern is simple, clean, and production-ready.
