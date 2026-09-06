# Worlds 0.2 tests

```text
api.lua               0.2 public surface and compatibility break
compat.lua            Lua 5.1/library compatibility
attachment.lua         complete Att(K), global matching, locality, freshness
attachment_query.lua   retained Hit/Retry/Unknown search and invalidation
harden.lua             opaque Lua trust boundary
certified.lua          actual + detached-patch certification
separate.lua           portable geometry using attachment/graft
frontier.lua           frontier abstraction and separate invocation
stress_attachment.lua  deterministic generated attachment/query stress
```

`regression.lua` exercises higher-order grafting, capture, repeated unfolding, alternatives and one-shot continuations through the attachment/graft model.
