# http-nu Current Changes Summary

**Date**: 2025-12-20
**Repository**: vilara-chuck/http-nu
**Current HEAD**: 1d24cde

This document summarizes changes to http-nu from v0.6.0 through the current HEAD.

## v0.6.0 Release Highlights

Released 2025-12-05 with these features:

- **Dynamic script updates via stdin** - Scripts can be updated at runtime without restarting the server
- **Minijinja template rendering** - New `.mj` command for rendering minijinja templates
- **Brotli compression** - Added brotli compression with streaming support
- **Multi-value headers** - Support for multi-value headers using list syntax
- **Nushell 0.109.1** - Updated to the latest Nushell version

## Post-v0.6.0 Changes (24 commits)

### Major New Features

#### HTTP/2 Support and Graceful Shutdown
**Commit**: faa913a (2025-12-06)

- Uses hyper-util auto builder for HTTP/1 + HTTP/2 auto-detection
- Tracks inflight connections with GracefulShutdown for clean termination
- Configures ALPN protocols for HTTP/2 over TLS

#### Embedded Routing Module
**Commit**: 12a164a (2025-12-11)

Declarative HTTP routing embedded at compile time, available via `use http-nu/router *`.

Features:
- Path matching: `{path: "/health"}` or `{path-matches: "/users/:id"}`
- Method/header filters: `{method: "POST", has-header: {accept: "..."}}`
- Closure escape hatch for custom logic: `{|req| if ... { {} }}`
- Fallback routing: `route true`
- Returns 501 when no routes match

#### HTML DSL Module
**Commit**: eff44ab (2025-12-15)

Nushell DSL for HTML generation with `h-` prefixed commands.

```nushell
use http-nu/html *

h-div {class: "card"} {
  h-h1 "Title"
  | h-p "Content"
}
```

Features:
- All HTML5 elements with `h-` prefix
- Pipe siblings, nest via closures
- Returns string directly (no `str join` needed)
- Void tags handled per spec (img, br, input, etc.)

#### Datastar SSE SDK Module
**Commit**: be45ed0 (2025-12-15)

Server-Sent Events integration for the Datastar hypermedia framework. Enables reactive web applications with SSE support.

### HTML DSL Improvements

After the initial HTML DSL release, several enhancements were added:

| Commit | Feature |
|--------|---------|
| 1101c0 | Style attribute accepts records |
| 1294beb | `+tag` append variants for sibling elements |
| 66afe78 | Variadic args, class lists, recursive children |
| 17090fc | Boolean attributes support |
| 5a0ad4a | Style values accept lists for comma-separated CSS |
| 1d24cde | UPPERCASE TAG VARIANTS for shouty style |

### Infrastructure and Refactoring

- **Request body streaming** (8341369) - Stream request body through dispatch to handlers
- **Examples refactored** (10a91c0) - Use HTML DSL, unquoted methods, content negotiation
- **README reorganized** (ccc53b4) - Added Reference section and Embedded Modules documentation
- **CI improvements** - Nushell installed for running tests

## Commit Log (v0.6.0 to HEAD)

```
1d24cde feat(html): ADD UPPERCASE TAG VARIANTS FOR THE SHOUTY STYLE
c63da80 feat(html): style values accept lists for comma-separated CSS
5a0ad4a docs(html): document boolean attributes
17090fc feat(html): support boolean attributes
0325b1f fix(html): handle empty args for nushell <0.109 compat
66afe78 feat(html): variadic args, class lists, recursive children
0aca4d2 docs(datastar): add mathml to namespace options
1101bc9 feat(html): allow style attribute to be a record
10a91c0 refactor(examples): use HTML DSL, unquoted methods, content negotiation
70c9c0e chore: lint test_html.nu
1294beb feat(html): add +tag append variants for sibling elements
ccc53b4 docs: reorganize README with Reference section and Embedded Modules
4e02dc7 refactor(examples): use append pipelines in datastar-sdk
8341369 refactor(router): stream request body through dispatch to handlers
1a3effa feat: add datastar-sdk example and fix from datastar-request API
fea5571 docs: simplify quotes example with nushell and posix examples
e5d64a7 refactor(html): use _ prefix and explicit append for siblings
e5cbf4a style: use raw strings in tests and apply nushell formatting
0ad7097 test: export attrs-to-string and add tests
cd66f4f docs: document HTTP/2 support in TLS section
be45ed0 feat: add Datastar SSE SDK module (#31)
eff44ab feat: add HTML DSL module (#30)
12a164a feat: add embedded routing module
faa913a feat: add HTTP/2 support and graceful shutdown
```

## Implications for Vilara

These changes significantly enhance http-nu's capabilities for building web applications in pure Nushell:

1. **HTML DSL** - Eliminates string concatenation for HTML generation, making templates more maintainable
2. **Embedded routing** - Declarative routing removes boilerplate from request handling
3. **Datastar integration** - Enables reactive UIs without JavaScript framework complexity
4. **HTTP/2** - Modern protocol support for production deployments

The combination of HTML DSL + Datastar SDK + routing module provides a complete stack for building hypermedia-driven web applications entirely in Nushell.
