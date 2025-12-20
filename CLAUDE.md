# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**gl.je** - Event-sourced double-entry accounting system. The name combines General Ledger (GL) with Journal Entry (JE), the fundamental unit of double-entry bookkeeping.

See README.md for full documentation on usage, commands, and examples.

## Running the System

```bash
# Terminal 1: Start xs server
xs serve ~/.local/share/gl-demo

# Terminal 2: Nushell session
$env.XS_ADDR = ("~/.local/share/gl-demo" | path expand)
use xs.nu *
use gl.nu *
```

## Planned Work (planning/)

All planning documents are maintained in planning/.
