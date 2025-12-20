# Experiment Directory Index

## Start Here

1. **README.md** - Overview and quick start guide
2. **QUICK-REFERENCE.md** - TL;DR pattern you can copy
3. **RECOMMENDED-PATTERN.nu** - Production-ready template to use

## Documentation

- **README.md** - Experiment overview, results summary, and getting started
- **QUICK-REFERENCE.md** - Quick copy-paste pattern with minimal explanation
- **FINDINGS.md** - Comprehensive analysis, approach comparison, and insights
- **INDEX.md** - This file (directory structure and navigation)

## Working Examples

### Main Examples
- **RECOMMENDED-PATTERN.nu** - Full-featured example with comprehensive comments
  - Multiple commands with flags
  - Error handling
  - Usage help
  - Best practices demonstrated

- **real-world-example.nu** - Practical blueprint management tool
  - Realistic use case
  - Complex commands
  - Multiple features
  - Production-like structure

### Approach Comparisons
- **approach1-main-wrapper.nu** - Simple main wrapper pattern (recommended)
- **approach2-conditional.nu** - Alternative argument handling style
- **approach3-dual-namespace.nu** - Advanced pattern with internal/external split

## Test Scripts

- **test-runner.nu** - Automated validation of all three approaches
- **test-module-import.nu** - Tests module import mode specifically

## Directory Structure

```
/tmp/nu-command-experiment/
├── INDEX.md                      # This file
├── README.md                     # Start here
├── QUICK-REFERENCE.md            # Quick pattern guide
├── FINDINGS.md                   # Detailed analysis
├── RECOMMENDED-PATTERN.nu        # Production template
├── real-world-example.nu         # Practical example
├── approach1-main-wrapper.nu     # Pattern 1 (recommended)
├── approach2-conditional.nu      # Pattern 2 (alternative)
├── approach3-dual-namespace.nu   # Pattern 3 (advanced)
├── test-runner.nu                # Test all approaches
└── test-module-import.nu         # Test module imports
```

## Usage Paths

### For Quick Start
1. Read **QUICK-REFERENCE.md**
2. Copy **RECOMMENDED-PATTERN.nu**
3. Modify for your needs

### For Understanding
1. Read **README.md**
2. Review **FINDINGS.md**
3. Study **approach1-main-wrapper.nu**
4. Compare with other approaches

### For Testing
1. Run `nu -l -c "source test-runner.nu"`
2. Try direct execution: `./RECOMMENDED-PATTERN.nu list`
3. Try module import: `nu -l -c "use RECOMMENDED-PATTERN.nu *; demo list"`

### For Real-World Reference
1. Study **real-world-example.nu**
2. See how features are organized
3. Note error handling patterns
4. Observe command structure

## Key Findings

All approaches successfully achieve:
- ✅ Zero code duplication
- ✅ Dual-mode operation (executable + module)
- ✅ Bash-style subcommand behavior
- ✅ Type safety in business logic
- ✅ Clean separation of concerns

**Recommended**: Use approach1-main-wrapper pattern for most cases.

## File Sizes

- Documentation: ~18KB (README + QUICK-REFERENCE + FINDINGS)
- Examples: ~14KB (all .nu files)
- Total: ~32KB

All files are standalone and self-contained.
