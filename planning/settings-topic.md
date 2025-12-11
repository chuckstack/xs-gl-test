# GL Settings Topic

## Overview

Store application settings on the stream for handler configuration.

## Topic

| Topic | TTL | Writer | Purpose |
|-------|-----|--------|---------|
| `gl.settings` | head:1 | user | Configuration settings |

## Usage

### Set Settings

```nu
.append gl.settings --meta {
  max_amount: 1000000
  require_description: true
} --ttl "head:1"
```

### Read in Handler

```nu
# At handler startup (outside run:)
$env.GL_SETTINGS = try { .head gl.settings | get meta } catch { {} }

{
  run: {|frame|
    let max = $env.GL_SETTINGS.max_amount? | default 10000000
    # use in validation...
  }
}
```

## Benefits

- Settings are on the stream (auditable, versioned)
- Change settings by appending new frame
- TTL `head:1` keeps only latest
- Handlers read settings at registration time

## Considerations

- Handlers must be re-registered to pick up new settings
- Alternative: read `.head gl.settings` inside `run:` for dynamic settings (but adds overhead per frame)

## Implementation Status

- [ ] Add settings topic support
- [ ] Update handlers to read settings
- [ ] Document available settings
