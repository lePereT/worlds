# API

**Status: maintained public Lua API for Worlds 0.6.3.**

```lua
local W = require('worlds')
```

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

Builders keep their mutable construction state in lexical closures; no membership or carrier arrays are exposed on the Builder value. Builders validate the Geometry laws, including producer/consumer uniqueness, acyclic Face/Strand causality and causal availability of existing/fresh local structure. Public array arguments must be dense Lua arrays; holes or non-positive/non-integral keys are rejected rather than silently truncated.

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

Names are not semantic identity. Returned incidence arrays are copies.

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

Construction.is_construction(c)
```

A Construction is immutable evidence of one exact `join` materialisation.
`Construction.join(P,E)` performs the ordinary `W.join(P,E)` operation; it does
not introduce another Geometry-changing primitive or composition algorithm.
The stored parts are the ordered exact Geometry values supplied to that join,
the stored equations are a normalised immutable copy, and `image(x)` exposes the
exact construction-relative carrier image returned by the kernel.

Accessor arrays are copies.  The image table itself is not exposed.

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

A Presentation is an immutable ordered, non-authoritative view of selected exact
open Strand occurrences relative to one exact ambient Geometry.  Every
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

History observes transitions only. It is never consulted by `solve`, `join` or
`advance`.
