#!/usr/bin/env nu

# Test runner to validate all approaches

print "="
print "Testing Nushell Script Dual-Mode Patterns"
print "="
print ""

# Test Approach 1
print "--- Approach 1: Main Wrapper ---"
print ""

print "Test 1a: Direct execution with no args"
bash -c "cd /tmp/nu-command-experiment && nu approach1-main-wrapper.nu"
print ""

print "Test 1b: Direct execution - tool list"
bash -c "cd /tmp/nu-command-experiment && nu approach1-main-wrapper.nu list"
print ""

print "Test 1c: Direct execution - tool create"
bash -c "cd /tmp/nu-command-experiment && nu approach1-main-wrapper.nu create myitem"
print ""

print "Test 1d: Module import and use"
use approach1-main-wrapper.nu *
tool list
print ""
let result = (tool create "test-item")
print $result
print ""

# Test Approach 2
print "--- Approach 2: Conditional Execution ---"
print ""

print "Test 2a: Direct execution with no args"
bash -c "cd /tmp/nu-command-experiment && nu approach2-conditional.nu"
print ""

print "Test 2b: Direct execution - bp list"
bash -c "cd /tmp/nu-command-experiment && nu approach2-conditional.nu list"
print ""

print "Test 2c: Direct execution - bp create"
bash -c "cd /tmp/nu-command-experiment && nu approach2-conditional.nu create webapp frontend"
print ""

print "Test 2d: Module import and use"
use approach2-conditional.nu *
bp list
print ""
let result = (bp create "test-bp" "testing")
print $result
print ""

# Test Approach 3
print "--- Approach 3: Dual Namespace ---"
print ""

print "Test 3a: Direct execution with no args"
bash -c "cd /tmp/nu-command-experiment && nu approach3-dual-namespace.nu"
print ""

print "Test 3b: Direct execution - cmd list"
bash -c "cd /tmp/nu-command-experiment && nu approach3-dual-namespace.nu list"
print ""

print "Test 3c: Direct execution - cmd create"
bash -c "cd /tmp/nu-command-experiment && nu approach3-dual-namespace.nu create delta"
print ""

print "Test 3d: Module import and use"
use approach3-dual-namespace.nu *
cmd list
print ""
let result = (cmd create "test-cmd")
print $result
print ""

print "="
print "All tests completed!"
print "="
