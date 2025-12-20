#!/usr/bin/env nu

# Test importing RECOMMENDED-PATTERN as a module

print "Testing module import mode..."
print ""

print "Importing module..."
use RECOMMENDED-PATTERN.nu *
print ""

print "Test 1: demo list"
demo list
print ""

print "Test 2: demo create with flags"
let result = (demo create "module-test" --type "testing" --active)
print $result
print ""

print "Test 3: demo info"
demo info "alpha"
print ""

print "Test 4: demo delete without force"
let delete_result = (demo delete "test-item")
print $delete_result
print ""

print "Test 5: demo delete with force"
let delete_forced = (demo delete "test-item" --force)
print $delete_forced
print ""

print "Module import tests completed!"
