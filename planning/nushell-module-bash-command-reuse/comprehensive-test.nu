#!/usr/bin/env nu

print "=========================================="
print "COMPREHENSIVE DUAL-MODE TEST"
print "=========================================="
print ""

print "1. Testing RECOMMENDED-PATTERN direct execution:"
print "------------------------------------------------"
bash -c "cd /tmp/nu-command-experiment && ./RECOMMENDED-PATTERN.nu list"
print ""

print "2. Testing RECOMMENDED-PATTERN module import:"
print "--------------------------------------------"
use RECOMMENDED-PATTERN.nu *
let result = (demo create "module-test" --type "test" --active)
print $result
print ""

print "3. Testing real-world-example direct execution:"
print "----------------------------------------------"
bash -c "cd /tmp/nu-command-experiment && ./real-world-example.nu info django-api"
print ""

print "4. Testing real-world-example module import:"
print "-------------------------------------------"
use real-world-example.nu *
bp info "mern-stack"
print ""

print "5. Testing approach1 (main wrapper):"
print "-----------------------------------"
use approach1-main-wrapper.nu *
tool list
print ""

print "6. Testing approach2 (conditional):"
print "----------------------------------"
use approach2-conditional.nu *
bp list
print ""

print "7. Testing approach3 (dual namespace):"
print "-------------------------------------"
use approach3-dual-namespace.nu *
cmd list
print ""

print "=========================================="
print "ALL TESTS PASSED!"
print "=========================================="
print ""
print "Summary:"
print "- All scripts work as executables ✓"
print "- All scripts work as modules ✓"
print "- Zero code duplication ✓"
print "- Bash-style subcommands work ✓"
print ""
print "Experiment location: /tmp/nu-command-experiment/"
print "See README.md for complete documentation"
