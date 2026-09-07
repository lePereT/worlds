# API

**Status: maintained public Lua API for Worlds 0.5.0.**

## Geometry

```lua
local G = Worlds.Geometry
local b = G.builder()
local root = b:membrane(nil, 'root')
local p = b:point(root, 'p')
local s = b:strand(root, {p})
local g = b:finish()
```

Geometry builders create exact finite open 2-complexes.  Strands may carry
Points imported from other Geometries as rigid exact identities.

Face input/output incidence is semantically a finite set. `Geometry.inputs(face)` and `Geometry.outputs(face)` return compact enumeration arrays for convenience and performance; their enumeration order is unspecified and carries no semantic meaning. Strand Point incidence remains ordered.

Useful queries include:

```lua
g:ingress()
g:egress()
g:producer(strand)
g:consumer(strand)
g:grounded()
```

## Cut

```lua
local q = Worlds.Cut.query(process, {
    strands = {[process_input] = exact_offer},
    offers = other_exact_offers,
})

local kind, cut = q:step(1000)
```

A retained query returns `Hit`, `Retry` or `Unknown`.  Work budgets count
candidate checks, not elapsed time.

## Algebra

```lua
local tensor, images = Worlds.Algebra.tensor{P, Q}

local composite = Worlds.Algebra.close(
    {P, Q},
    {{P_output, Q_input}}
)
```

Each link connects distinct exact Strand occurrences. A Strand which is both ingress and egress cannot be linked to itself.

For long constructions use one assembly and materialise once:

```lua
local a = Worlds.Algebra.builder()
a:add(P)
a:add(Q)
a:cut(P_output, Q_input)
local composite = a:finish()
```

`Algebra.admissible(process, cut)` is the causal-authority judgement required
for actual development.

## Operational

```lua
local state = Worlds.Operational.from_geometry(initial)

local q = Worlds.Operational.query(state, process, {
    strands = {[process_input] = live_strand},
})

local kind, witness = q:step(1000)
if kind == 'Hit' then
    local state, image = Worlds.Operational.commit(witness)
end
```

Operational state is intentionally tiny: an exact set of live egress Strand
occurrences plus its size.  Membrane identity is not an authority-discovery API.
