#!/usr/bin/env bash

# Initialize all git submodules for the xs-gl-test project after cloning

echo "Initializing xs-gl-test submodules..."

# Initialize and update all submodules to their recorded commits
git submodule update --init --recursive

# Ensure each submodule is on its main branch (not detached HEAD)
# This creates/checks out the branch but stays at the commit specified by the parent repo
echo -e "\nChecking out tracking branch for each submodule..."
git submodule foreach 'branch=$(git config -f $toplevel/.gitmodules submodule.$name.branch || echo "main"); git checkout -B $branch 2>/dev/null || git checkout -B master 2>/dev/null || echo "Staying in detached HEAD for $name"'

echo -e "\nSubmodule initialization complete!"
echo -e "\nCurrent submodule status:"
git submodule status
