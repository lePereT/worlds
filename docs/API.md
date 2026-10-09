# API

**Status: maintained public Lua API for Worlds 0.6.6.**

```lua
local W = require('worlds')
```

## Trust and finite arrays

Worlds assumes cooperating in-process clients. Finite array arguments and array
views returned by the API are **borrowed read-only Lua tables**. Worlds validates
new semantic claims but does not defensively clone these arrays. Callers must not
mutate an array after passing it to Worlds while retained, or mutate an array
returned by Worlds. Copy explicitly at an application boundary when a mutable
owned table is required.

Canonicalisation may still allocate once where representation genuinely changes,
for example normalised equations or set-like Question sections. See `TRUST.md`.

## Build Geometry

```lua
local b = W.builder()
local root = b:membrane(nil, 'root')
local p = b:point(root, 'p')
local input = b:strand(root, {p}, 'in')
local output = b:strand(root, {p}, 'out')
b:face(root, {input}, {output}, 'step')
local development = b:finish()
```

Builder methods are:

```lua
b:membrane(parent_or_nil, name_or_nil)
b:point(membrane, name_or_nil)
b:strand(membrane, ordered_points_or_nil, name_or_nil)
b:face(membrane, input_strands_or_nil, output_strands_or_nil, name_or_nil)
b:finish()  -- builder is consumed
```

Builders keep their mutable construction state in lexical closures; no membership or carrier arrays are exposed on the Builder value. Builders validate the Geometry laws, including producer/consumer uniqueness, acyclic Face/Strand causality and causal availability of existing/fresh local structure. Public array arguments must be dense Lua arrays; holes or non-positive/non-integral keys are rejected rather than silently truncated. Point-incidence and Face-incidence arrays are retained as borrowed read-only inputs rather than cloned.

## Carrier queries

```lua
W.kind(x)       -- 'membrane' | 'point' | 'strand' | 'face' | nil
W.name(x)
W.parent(m)
W.membrane(point_or_strand_or_face)
W.points(strand)
W.inputs(face)
W.outputs(face)
W.is_geometry(x)
```

Names are not semantic identity. Returned incidence arrays are borrowed read-only views and are stable by identity.

## Geometry queries

```lua
g:membranes()
g:points()
g:strands()
g:faces()
g:ingress()
g:egress()
g:is_developable()

g:owns_membrane(x)
g:owns_point(x)
g:owns_strand(x)
g:owns_face(x)

g:producer(strand)
g:consumer(strand)
g:is_input(strand)
g:is_terminal(strand)
```

Geometry carrier, ingress and egress arrays are borrowed read-only views; repeated access does not allocate a defensive copy.

## boundary

```lua
local live = W.boundary(g)
```

`boundary(g)` preserves exact egress Strands, owned Points incident on those
Strands, and owned Membrane ancestry needed to interpret them. It contains no
Faces. Calling `boundary` on an already boundary-normal Geometry returns it.

## solve

The ordinary complete-matching convenience remains:

```lua
local q = W.solve(world, development, {
  {from = exact_world_egress, to = development_ingress}, -- optional seed
})

while true do
  local tag, value = q:step(1000)
  if tag == 'yes' then
    local equations = value
  elseif tag == 'more' then
    -- retain q and provide more fuel later
  elseif tag == 'done' or tag == 'no' then
    break
  end
end
```

`W.solve` means complete matching of all development ingress against all world
egress. Its third argument is only an optional array of exact seed equations.
Named policy fields are rejected.

General finite judgement policy belongs to `worlds.query`:

```lua
local Query = require('worlds.query')

local matching = Query.match(world, development, {
  sources = selected_world_egress,
  targets = selected_development_ingress,
  required_sources = {},
  required_targets = selected_development_ingress,
  admissible = exact_pairs,
  seeds = exact_seed_equations,
})

local closure = Query.close({part_a, part_b}, {
  sources = selected_open_egress,
  targets = selected_open_ingress,
  required_sources = must_be_consumed,
  required_targets = must_be_closed,
  admissible = exact_pairs,
  seeds = exact_seed_equations,
})

local q = Query.solve(closure)
```

`Match(A,B;S,T,D,R,C,E0)` is directional target realisation.
`Close(P;S,T,D,R,C,E0)` is direct finite closure over ordered disjoint Geometry
parts. In both forms `D` defaults to empty, `R` defaults to selected targets,
and every `yes(E)` is guaranteed to be consumable by strict
`join(question:parts(),E)`. The vague `Query.new` constructor is absent.

Question finite-section and evidence accessors return stable borrowed read-only views.
Canonicalised sections are normalised once at Question construction; observing them does
not allocate another copy. Refutation reasons follow the same borrowed-view contract.

See `QUERY.md` for the exact definitions and evidence semantics.

## join

```lua
local composite, image = W.join(
  {world_part, development_part},
  equations
)
```

Parts must be disjoint Geometry values. Each equation joins a distinct open
`from` egress to an open `to` ingress. The source and target occurrences are
identified together with their induced Point/Membrane equations.

The first part is the frame. Unaffected frame carriers are reused literally;
later-part carriers are instantiated or identified as required. `image[x]`
gives the resulting carrier corresponding to an input carrier `x`. Several
Faces in a causal SCC may share the same joint-Face image.

## advance

```lua
local next_world, image = W.advance(world, development, equations)
```

This is the live-runtime convenience:

```text
boundary(join({boundary(world), development}, equations))
```

It is definitionally the ordinary `boundary` and `join` operations, not a
separate execution path.


## Construction witness

```lua
local Construction = require('worlds.construction')

local c = Construction.join(parts, equations)
local ps = c:parts()
local es = c:equations()
local result = c:result()
local mapped = c:image(source_carrier)
local correspondence = c:correspondence()

Construction.is_construction(c)
Construction.is_correspondence(correspondence)
```

A Construction is immutable evidence of one exact `join` materialisation.
`Construction.join(P,E)` performs the ordinary strict join law; it does not
introduce another Geometry-changing primitive or composition algorithm. The
stored parts are the ordered exact Geometry values supplied to that join, the
stored equations are normalised once, and `image(x)` exposes the surviving exact
carrier image returned by the kernel. The supplied parts array and normalised
equation array are borrowed read-only views. The image table itself is not
exposed.

### `Construction.try_join(parts, equations)`

Non-exceptional exact composition judgement for client-supplied cuts. Malformed
API inputs still raise. A dense, well-formed equation set which cannot form a
lawful Worlds quotient returns `nil, reason`. Success returns the same immutable
`Construction` witness as `Construction.join`. Positive Query realisations are
reused exactly as by strict `join`.

Use `try_join` when geometric incompatibility is an expected semantic outcome;
use `join` when the caller already possesses a lawful witness or an invalid cut
is a programming error.

### Construction correspondence

0.6.6 adds an optional immutable view of the Construction's native quotient
provenance:

```lua
local q = c:correspondence()

local source_parts = q:source_parts()
local target = q:target()
local a = q:source_class(source_carrier)
local b = q:target_class(result_carrier)
local y = q:survivor(source_carrier)

local same = q:source_equivalent(source_a, source_b)
local reaches = q:corresponds(source_carrier, result_carrier)

local composed = q:compose(next_construction:correspondence())
local same_partition = q:same_source_partition(other_correspondence)
local peer = q:mate(other_correspondence, result_carrier)
```

A correspondence class is opaque construction-relative evidence. It is not a
Membrane, Point, Strand or Face, `W.kind(class)` is `nil`, and possession of a
class grants no authority. Equality of class values is meaningful only within
the corresponding immutable witness.

`source_class(x)` preserves quotient identity even when the class containing
`x` has no surviving result carrier. `target_class(y)` reports the class of a
result carrier. `survivor(x)` returns the unique exact target carrier in the
same quotient class as marked source carrier `x`, or `nil` when that class is
annihilated (and for values outside the marked source). `source_equivalent(a,b)`
asks whether two marked source carriers were identified by this Construction;
`corresponds(a,b)` asks whether a source carrier and result carrier belong to
the same class.

`compose(next)` composes correspondence evidence when `next` consumes this
correspondence's target Geometry, optionally with genuinely fresh additional
parts. It rejects overlap between those fresh parts and the original marked
source. The operation composes evidence only; it does not perform another join.
On a composed correspondence, `survivor(x)` follows the source-relative class
through the whole composed relation; it is therefore not merely an alias for
the first Construction's `image(x)`.

`same_source_partition(other)` compares exact quotienting over an identical
marked source. `mate(other,y)` uses that common source partition to identify the
unique source-relative peer of target carrier `y` in another exact-distinct
Construction result, when one exists.

`Construction:image` remains the simple surviving-carrier projection and is
unchanged. `W.join` likewise retains its existing two-result API and does not
retain correspondence provenance. Construction requests the richer witness
explicitly from the verified centre.

## Presentation

```lua
local Presentation = require('worlds.presentation')

local p = Presentation.new(g, {
  {s1, s2},
  {s3},
})

local first = p:row(1)
local rows = p:rows()
local g0 = p:ambient()

Presentation.is_presentation(p)
```

A Presentation is an immutable-by-contract ordered, non-authoritative view of selected exact
open Strand occurrences relative to one exact ambient Geometry. Its row arrays are borrowed read-only views rather than copied storage.  Every
coordinate must be a Strand owned by the ambient Geometry and open there (no
producer or no consumer).  Rows and coordinate arrays must be dense, but rows
may be empty and coordinates may be omitted or repeated.

Row order, coordinate order and multiplicity are semantics of the Presentation
only.  They do not alter Geometry, grant authority, impose causal order or make
hidden authority public.  Multiple different Presentations may describe the
same Geometry.

### Presentation transport

```lua
local residual = p:transport(c)
```

`c` must be a Worlds Construction and `p:ambient()` must be exactly one of
`c:parts()`.  Transport maps every coordinate pointwise through `c:image` and
retains it exactly when the image is a Strand which remains open in
`c:result()`.  Row order and coordinate multiplicity are preserved; mapped
coordinates which become internal or disappear under causal SCC normalisation
are omitted from the residual Presentation.

Transport performs no matching, joining, sequencing or completion.  In
particular:

```lua
Presentation.new(g, {
  {arg},
  {},
})
```

states only that the second presented row is empty.  If a programme requires
completion authority, Geometry must contain a genuine Strand carrying it.

Presentation is an in-memory relative view.  Persistent package formats must
encode their own ambient-relative exact coordinates and reconstruct a
Presentation after import.

## Optional history

```lua
local History = require('worlds.history')
local h = History.new()
local next_world, image = h:advance(world, development, equations)
print(h:count())
for _, event in ipairs(h:events()) do
  -- event.development
  -- event.equations
  -- event.faces       -- development Face -> resulting Face
end
```

`h:events()` is a stable borrowed read-only view. Event equation arrays are likewise
borrowed; History observes exact execution and does not clone evidence merely for
ownership isolation.

History observes transitions only. It is never consulted by `solve`, `join` or
`advance`.
