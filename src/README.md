# Worlds 0.3 source map

```text
src/
  worlds.lua
  worlds/
    model.lua        four-carrier storage: World / Point / Strand / Face
    topology.lua     derived detached patch and boundary topology
    att.lua          the single Att_F(P) relation, exact Witnesses, residual Frontiers and Cuts
    graft.lua        fresh actualisation of a live exact Witness
    audit.lua        resource, provenance and causal checks
    harden.lua       public Model facade
    harden_core.lua  Lua trust-boundary implementation
    internal.lua     package-internal hardened adapter
    certified.lua    immutable certified geometric Reader
    separate.lua     portable detached geometry
    completion.lua   retirement judgement
```

The carrier contains no search, residual, concurrency, conflict or frontier
metadata. `att.lua` derives all attachment geometry over an available Frontier.
An actual locality derives an initial Frontier; an exact Witness derives its
residual Frontier with `w:after()`. `w:cut()` exposes the exact internal cut of
one attached patch. Live actual Witnesses alone may `graft()`.

Independent exhaustive oracles live under `tests/reference/`, never under
`src/`.
