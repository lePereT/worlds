# API

**Status: maintained public Lua API for Worlds 0.6.0.**

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

General finite matching policy belongs to `worlds.query`:

```lua
local Query = require('worlds.query')

local question = Query.new(world, development, {
  sources = {world_egress_x, world_egress_y},
  targets = {development_ingress_a, development_ingress_b},
  required = {development_ingress_a},
  admissible = {
    {from = world_egress_x, to = development_ingress_a},
    {from = world_egress_y, to = development_ingress_b},
  },
  seeds = {
    {from = world_egress_x, to = development_ingress_a},
  },
})

local q = Query.solve(question)
```

The mathematical normal form is `Q = (A,B,S,T,R,C,E0)`. `sources`, `targets`, `required`, `admissible` and `seeds` are the complete set of accepted specification fields and denote finite exact sets/relations; unknown fields are rejected. Their presentation order is not semantic, and each finite collection must be supplied as a dense Lua array.

Targets in `T` but not `R` may remain open. A source/target pair not present in
`C` is simply outside the Question. There are therefore no `optional_ingress` or
`forbid` modes in the Geometry kernel.

A retained query distinguishes semantic result from incomplete work:

- `yes` — one constructive exact solution;
- `no` — the exact finite Question is exhausted with no solution;
- `more` — the work budget has not yet decided it;
- `done` — one or more solutions were emitted and enumeration is exhausted.

`step(fuel)` uses work units, not elapsed time. `more` is never semantic
refutation.

See `QUERY.md` for the matching judgement and complete definition.

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
