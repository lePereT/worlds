# Worlds 0.3.0

Worlds is a small executable semantic geometry built from four carrier objects:

```text
World   locality and actuality
Point   semantic identity
Strand  one occurrence of authority
Face    causal transformation
```

0.3 has one derived possibility relation:

```text
Att_F(P)
```

`P` is a detached open patch and `F` is an available Frontier. An actual World
and an exact residual cut both derive Frontiers; they use the same matcher.
There is no separate attachment, residual or concurrency subsystem.

## Public surface

```lua
local Worlds = require('worlds')

Worlds.Model
Worlds.Att
Worlds.Certified
Worlds.Separate
Worlds.Completion
```

The carrier remains unchanged from 0.2.

## Construct geometry

```lua
local m = Worlds.Model.new('Omega')
local K = m:world('K', m.actuality)
local P = m:point('identity', m.actuality, 'Identity')
local s = m:strand('authority', K, {P}, 'Authority')
```

Detached Worlds contain possible geometry. `Worlds.Att.patch(m, seed)` derives
an attachable open patch from that geometry; no Patch object is stored in the
carrier.

## Complete attachment

```lua
local F = Worlds.Att.at(m, K)
local patch = Worlds.Att.patch(m, gate)
local q = F:query(patch)
local status, evidence = q:step(100)
```

The result is `hit`, `retry` or `unknown`. Search budget is never semantic.
`F:witnesses(patch)` exhaustively returns exact Witnesses for small/research
uses.

A Witness fixes one complete attachment. It may expose its exact support and
bindings and can be revalidated directly without rerunning search.

## Residual development

```lua
local w = F:witnesses(patch)[1]
local R = w:after()
```

`R` is another available Frontier. It contains the exact authority remaining
after `w` plus exact symbolic egress produced by `w`. No carrier geometry is
created and no rematching occurs.

The same relation applies again:

```lua
local later = R:witnesses(other_patch)
```

Thus causal enablement across different patches is ordinary `Att_F(P)` over a
residual Frontier.

For the internal causal geometry of one exact patch:

```lua
local cut = w:cut()
local enabled = cut:enabled()
local next_cut = cut:after(enabled[1])
```

A Cut is proof geometry only; it is not another carrier.

## Derived higher geometry

`Worlds.Att.coherence(frontier, witnesses)` asks whether exact occurrences form
a coherent cubical family. It derives one residual vertex per subset and checks
every induced face map.

Consequently:

```text
causality     later exact occurrence consumes symbolic egress/fresh identity
local conflict individually possible occurrences fail coherent co-completion
independence  exact occurrences complete a coherent cube
```

None is stored as metadata or promoted to a carrier object.

The conflict is deliberately local to a Frontier. An occurrence may consume a
resource and produce a fresh successor resource, enabling a new later occurrence
of a currently competing patch.

## Graft

A Witness over a live actual Frontier may be actualised:

```lua
local instance = w:graft()
```

Graft creates fresh actual geometry. A Witness over an immutable certified or
residual Frontier cannot graft.

## Read-only geometry

The same `Att` relation operates over `Worlds.Certified.Reader` geometry. This
is important for compilers and other consumers: they need not reconstruct a
Model to explore certified semantic possibilities.

## Separate compilation

`Worlds.Separate` transports detached geometry. Language/compiler-specific
frontier variables or generic interface policies do not belong to Worlds and
are intentionally absent from 0.3.

## Source layout

See `src/README.md`. Independent exhaustive reference semantics live only under
`tests/reference/`.
