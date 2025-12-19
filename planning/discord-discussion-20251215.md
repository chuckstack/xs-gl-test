# Topics

## Notes:
- focused on xs patterns now (not yet reasoned about http-nu router/controller)

## Desire
- be able to tell llm what I want, and llm pick the applicable pattern for quick implementation

## xs Key Terms
- handler (frame handler per store) (responder)
- generator (frame generator per store)
- command (?)

## Projection Patterns
- from beginning to head (gl, aging, inventory, cash, settings)
- from beginning to as-of id (gl, aging, inventory, cash)
- from id to id (gl)
- from beginning to intermediate id to ending id (gl) => opening balance + transactions between ids + ending balance
- ttl backed by SQLite

## jsonschema
- tied to topic+action combination
- used in handler for post/fact pattern (below)

## Post vs Fact pattern
- capture all posts
- handler transposes to fact topic if valid
- Does not account for multiple handlers
  - in my world, people (my customers) will add additional handlers. with each handler comes the ability to have many approvals/validations. if any one approval fails, the record is invalid and should not be considered in a 'head' command,

## SQLite
- free with nushell (handler)
- xs.nu - hook for adding nushell+sqlite convenience commands (if needed)
- focus on reasonable hooks - not direct integration (menu of pre-built handlers?)

## Settings
- actions:
  - key-add to topic - dedicated action allows for dedicated handler(s)/validation(s) - needed in my world - ex: do not allow to duplicate key, allows setting at the same time
  - key-set in topic,
  - key-remove from topic - dedicated action allows for dedicated handler(s)/validation(s) - needed in my world - ex: do not remove key/account with non-zero balance,
- Notes:
  - add/remove might infer post/fact pattern
  - if only use key-set, then show not null (where null is soft remove)

## GL
- Queries
  - from beginning to current
  - from beginning to as-of id
  - from id to id - examples:
    - balance sheet: from beginning to ...
    - income statement: from period id to ...
    - trial balance: from id to ...

## Request
- hot potato call to action (user and/or role)
- has status + resolution

## Performance of Handler
- How deep is the queue if handler sleep 50000

## Application vs Framework
- ERP: one person creates and supports the framework and another adds based on the framework
- ERP: heavy use of plugins

## ERP (any open document where balance is defended)

### Inventory
- MR, ADJ, Move, Ship documents create material-transaction frames
- Queries
  - from beginning to current
  - from beginning to as-of id

### Aging (invoice adds and allocation subtracts)

### Cash

### Documents
- header + lines
- drafted => prepared => completed => closed (workflow)

## Reference

### Vocabulary Mapping
? (logical) <=> store (technical)
event (logical) <=> frame (technical)
stream (logical) <=> topic[] with motion (technical)
action (logical) <=> cmd (technical)
ephemeral (logical) <=> TTL (technical)

### jsonschema
- https://crates.io/crates/jsonschema crate
- https://github.com/supabase/pg_jsonschema
