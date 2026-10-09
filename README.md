# Worlds 0.6.6 — Construction correspondence and Lua 5.1 compatibility

Worlds is a small operational geometry in which exact identity, scarce
authority, causal transformation and locality arise from incidence and open
boundary.

Worlds 0.6.6 keeps the Membrane / Point / Strand / Face ontology and the
existing `boundary`, `join` and `advance` laws unchanged. The release adds one
piece of immutable evidence around ordinary Construction and repairs the
persistent boundary representation so the public API works under Lua 5.1 and
LuaJIT as well as newer Lua runtimes.

The public geometric centre remains:

```lua
local W = require('worlds')

-- ontology: Membrane / Point / Strand / Face / Geometry
-- operations: boundary / join / advance
```

`join(parts, equations)` remains the reference composition law. `advance` is
semantically `boundary(join(...))`; local/indexed paths are implementation
accelerations continuously checked against that definition.

## Construction correspondence

```lua
local Construction = require('worlds.construction')

local c = Construction.join(parts, equations)
local q = c:correspondence()
```

`Construction:image(x)` is unchanged and remains the surviving result carrier,
when one exists. `correspondence()` is richer immutable evidence of the exact
quotient established by that same Construction. It retains construction-local
classes even when a class is later annihilated and therefore has no final
carrier image. `correspondence:survivor(x)` gives the unique surviving exact
target of a marked source class, or `nil` when the class is annihilated, and
continues to do so after correspondence composition.

This evidence supports compositional knowledge transport and source-relative
comparison of exact-distinct Construction results without adding another Worlds
carrier or another composition law. Public class values are opaque evidence,
are not Worlds carriers, and grant no authority.

Ordinary `W.join` keeps its existing return values and does not retain this
provenance. Construction requests it explicitly from the verified centre.

See `docs/API.md` and `speculation/modern/native_construction_correspondence/`.

## Lua 5.1 and LuaJIT compatibility

Earlier 0.6.4/0.6.5 packages represented persistent boundary sequences as table
proxies whose array behaviour depended on table `__len`/iteration metamethods.
That works on newer Lua but is not a valid Lua 5.1/LuaJIT table contract.

0.6.6 separates the representations:

- persistent boundary sequences remain opaque internal tree/rope values;
- local updates retain their persistent/path-based mechanics;
- Worlds internals use explicit `length`, `get` and iterator operations;
- public Geometry boundary/carrier accessors expose cached ordinary dense Lua
  arrays, so `#`, `ipairs` and numeric indexing have normal Lua 5.1 semantics;
- the release gate scans all shipped Lua for post-5.1 syntax.

No fast path is disabled to obtain compatibility.

The Makefile discovers Lua in this order: LuaJIT, Lua 5.1, 5.2, 5.3, 5.4,
5.5, TeXLua. Set `LUA` explicitly to override discovery.

## Trusted in-process contract

Worlds validates new semantic claims, not immutable facts it has already
certified. Arrays exchanged with cooperating clients are borrowed read-only
views rather than defensive copies. Callers must not mutate borrowed state while
Worlds retains it. Private object state uses weak-key registries.

See `docs/TRUST.md`.

## Performance shape

The realtime programme from 0.6.4/0.6.5 remains intact:

- successful Questions retain strict-join realisation evidence;
- identity constructions are identity work;
- DSU state is allocated only where required;
- Construction images use dense or sparse representation according to shape;
- trusted Development builders validate once at `finish()`;
- prepared live boundaries support frame-aware matching and local `advance`;
- persistent boundary sections and disposable indexes preserve unchanged live
  structure across local evolution;
- Close rejects structurally impossible support pairs before deeper search.

The Lua 5.1 repair changes the boundary-sequence representation, not the
semantic or algorithmic envelope: persistent local updates remain persistent and
public array materialisation is cached at the API edge.

Performance acceptance remains based primarily on deterministic work ratchets,
not elapsed time. See `CHECKS.md`, `tests/work.lua` and
`tests/mechanical-work.lua`.

## Construction and Presentation remain edge evidence

```lua
local Construction = require('worlds.construction')
local Presentation = require('worlds.presentation')
```

Construction is exact evidence for one ordinary materialisation. Presentation
is ordered, non-authoritative ABI structure over selected open Strand
occurrences. Neither extends the ontology.

## Relay-facing research

`speculation/relay/` contains the strongest current Relay-facing work. It is organised
by research subject rather than as a generic research bucket:

- `relay/theory/` gives the restrictive occurrence-relative knowledge contract and
  its Construction/lifecycle pressures;
- `relay/computation/` gives package-first finite composition, recurrence, first-class
  formed computation, stable recursive Judgement, boundary viability and concurrency
  discovery.

The concurrency-discovery arena uses the same `choice`, `or_else`, `and_then`, `each`,
`together`, `form` and `perform` vocabulary across synchronous channels, three-party rendezvous,
grounded IVar/MVar state and derived one-place buffering. Open composition uses ordinary exact
Strand occurrences selected by a non-authoritative boundary Presentation, with positive Theory
supported on those occurrences and transported through Construction correspondence. No
match-signature object or facility-local composition algebra remains. The same `together` can
discover a rendezvous SCC, a grounded state request, a directed barrier, or causally independent
subgraphs; heterogeneous choice can contain channel receive, MVar take and a performed Form.
Persistent ownership also has a productive cyclic Package representation. Semaphore capacity is
scarce token topology, latch completion is positive all-token evidence, CAS is positive equality plus
ordinary preference, actor turns compose from mailbox/state protocols, cancellation consumes residual
authority, and external readiness remains an open environmental seam. Dynamically minted endpoint
identity can be an imported rigid Point rather than a string. The first memory-order pressure keeps
distinct atomic locations unordered until explicit synchronisation authority adds causality.

Run the promoted Relay research with:

```sh
make relay-check
```

## Validation

`make full-check` is the release semantic/differential/work gate.
`make speculation-check` runs the historical/general speculation corpus.
`make relay-check` runs the promoted Relay Theory and computation research.
`CHECKS.md` records the release verification shape.
