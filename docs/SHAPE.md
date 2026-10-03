# Shape of Worlds 0.6.5

Worlds has one small semantic centre and a disposable edge.

## Centre

`src/worlds/_centre.lua` owns only:

```text
Membrane  Point  Strand  Face
Geometry
boundary
join
Construction image
```

`join` is the sole Geometry-changing law. `boundary` forgets closed causal
history. The centre imports no query engine, cache, persistent sequence or live
fast path.

`advance` is intentionally *not* a centre primitive. The public edge implements
its defining equation

```text
boundary(join({boundary(world), development}, equations))
```

and may replace that calculation with an exact fast path.

## Disposable edge

`_fast.lua` contains exact local-join and single-Face refinements. `_index.lua`
contains the single rebuildable cache used both by finite-query compilation and
live-boundary updates. `_persistent.lua` is representation support for local
boundary edits.

All may be deleted without changing the meaning of Geometry. Fast paths return
`fallback` whenever their exact preconditions are not evident.

## Finite judgement

Questions remain outside Geometry. Search may use factorisation, Hall
feasibility and other finite algorithms, but every constructive answer is
validated by the centre's strict join law.

A successful search and a direct materialisation now use the same exact
`Construction` witness; `Realisation` is retained only as compatibility API
terminology, not as a second value kind.

## Optional edge utilities

`presentation` and `history` are descriptive/observational libraries. They own
no Geometry and are not imported by `require('worlds')` unless their services
are requested indirectly.
