# Worlds 0.6.1 — geometry kernel and finite Questions

Worlds is a small operational geometry in which exact identity, scarce authority,
causal transformation and locality arise from incidence and open boundary.

The release is deliberately split around a small verified centre:

```text
verified centre (`worlds._kernel`)
    exact carriers / Geometry / boundary / join / advance
             |
             | read-only observation
             v
public edge (`worlds`) + disposable acceleration
    outgoing structural index / complete solve convenience
             |
             v
finite Question judgement and replaceable query engines
    Match(A,B;S,T,D,R,C,E0) / Close(P;S,T,D,R,C,E0)
```

Worlds 0.6.1 tightens the 0.6 line without adding operational ontology: finite Question now distinguishes directional `Match` from direct finite `Close`; every constructive `yes(E)` is guaranteed to be consumable by strict `join`; and `join` validates the resulting quotient against the ordinary Geometry laws. The short-lived public `materialisable` probe is absent because lawfulness belongs to Question rather than a third semantic layer.

Only the verified Geometry centre is operational ontology. The compiled sidecar
is disposable acceleration derived from already-verified Geometry; a Question
carries no authority and is not programme state. The centre neither imports nor
registers acceleration.

The ordinary convenience surface remains small:

```text
solve(world, development)  -> complete matching question
join(parts, equations)     -> Geometry
boundary(Geometry)         -> future-relevant Geometry
advance(...)               = boundary(join(...))
```

`solve` is definitionally the complete-coverage special case of `worlds.query`.
It accepts only optional seed equations; specialised finite questions do not add
flags to the complete matching operation.

## Geometry kernel

A Geometry contains exact Membranes, Points, scarce Strand occurrences and causal
Faces. Ingress and egress are derived from incidence. `boundary(G)` keeps exactly
the future-relevant open authority and the owned structure required to interpret
it. Surviving carriers are preserved literally.

```text
boundary(boundary(G)) = boundary(G)
```

`join(parts,equations)` is the sole geometry-changing operation:

```text
disjoint union
+ directed open-boundary equations
+ typed equality closure
+ causal SCC quotient
+ locality support
= Geometry
```

The first part is the frame. Unaffected frame carriers survive literally; later
parts are instantiated fresh where they are not glued. Same-Geometry feedback is
ordinary boundary equality.

## Finite Questions

`worlds.query` exposes two exact judgement forms:

```text
Match(A,B;S,T,D,R,C,E0)   directional target realisation
Close(P;S,T,D,R,C,E0)     direct finite closure
```

`D` requires selected source occurrences to be consumed; `R` requires selected
target occurrences to be closed. `C` is the finite admissibility relation and
`E0` exact seeds. `Match` retains the stronger causal-development premise on its
target. `Close` asks directly whether equations over ordered disjoint parts yield
lawful Geometry; it is not staged through a product Geometry.

Both forms share `yes / no / more / done`, and every `yes(E)` is accepted by
strict `join(question:parts(),E)`. `W.solve(A,B,seeds)` remains the complete
Match special case.

See `docs/QUERY.md` for the maintained definitions.

## Matching judgement and engine

Matching is a real judgement and is not reducible to "`join` accepts these
equations". A target development contributes locality/equality constraints from
its internal open causal geometry. The query engine implements that judgement by:

1. compiling the source egress into structural rows with exact occurrence fibres;
2. quotienting target ingress by endpoint-thread locality equalities;
3. factorising only the irreducible boundary variables;
4. proving exact scarcity with Hall-style matching; and
5. enumerating exact Strand allocations only after structural feasibility.

These are algorithms, not semantic carriers. They live outside the verified
centre in `src/worlds/_kernel.lua` and may be replaced without changing the
Geometry or Question relations.

The engine retains only the source outgoing section, not closed source history.
Its ancestry caches, factors, support DAG and Hall structures are disposable.

## `yes`, `no`, `more`, `done`

A retained query distinguishes semantic result from incomplete work:

- `yes` — one constructive exact solution;
- `no` — the exact finite Question has no solution;
- `more` — the current work budget has not decided the Question;
- `done` — at least one solution was emitted and enumeration is exhausted.

`more` is never negative evidence. `no` is always relative to one exact finite
Question.

## Live computation

Runtime evolution can remain permanently at the boundary fixed point:

```lua
local q = W.solve(world, development)
local tag, equations = q:step(1000)
-- when tag == 'yes':
world, image = W.advance(world, development, equations)
```

`advance` is definitionally
`boundary(join({boundary(world), development}, equations))`. Optional
`worlds.history` may observe transitions but is never consulted by the kernel.

## Checks

`make full-check` runs the Geometry laws, finite-Question tests, optional-History
checks, adversarial cases, 10,000 ordinary differential cases, 5,000 selected-
section differential cases, more than 100,000 optional/admissibility assertions,
3,000 nested cases, 3,000 branching-locality cases, the historical algebra suite
and an architectural shape guard.

The shape guard explicitly rejects finite-question/search machinery from the
Geometry kernel.
