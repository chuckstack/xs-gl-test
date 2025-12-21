# Example: Accounts Prototype

Minimal prototype to vet concepts for the next gl.je release (see `planning/next-release-v1.md`).

## Purpose

Validate the dual-interface pattern:
- http-nu serves both CLI and web from same handler
- xs for event storage
- Datastar for reactive web UI
- Nushell CLI as HTTP client

## Files

- `serve.nu` - http-nu handler (owns xs, serves both interfaces)
- `gl-cli.nu` - CLI client (dual-mode: executable and module)

## Run

```bash
# Terminal 1: xs server (from repo root)
xs serve .local/store

# Terminal 2: http-nu server (from repo root)
export XS_ADDR=.local/store
cat example/serve.nu | http-nu :3001 -

# Terminal 3: CLI (from repo root)
./example/gl-cli.nu account activate cash asset
./example/gl-cli.nu account list

# Or browser: http://localhost:3001
```

## Reset

```bash
rm -rf .local/store
```
