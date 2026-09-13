# Worlds 0.6.0 — geometry kernel and finite matching judgements

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
finite matching judgement and replaceable query engine
    Question Q = (A,B,S,T,R,C,E0)
```

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

`worlds.query` asks a finite question about two exact ambient Geometries:

```text
Q = (A, B, S, T, R, C, E0)
```

where:

- `A` is the source/world Geometry;
- `B` is the target/development Geometry;
- `S` is an exact subset of `egress(A)`;
- `T` is an exact subset of `ingress(B)`;
- `R ⊆ T` are targets which must be matched;
- `C ⊆ S × T` is an optional exact admissibility relation;
- `E0 ⊆ C` are seeded equations.

A solution is an exact scarce equation set satisfying the Worlds matching
judgement plus those finite question parameters. The source and target roles are
kept distinct even when `A == B`.

The complete `W.solve(A,B,seeds)` case is simply:

```text
S = egress(A)
T = ingress(B)
R = T
C = S × T
E0 = seeds
```

Partial application, public views, local execution domains and open internal
closure therefore become different Questions rather than different kernel
operations.

See `docs/QUERY.md` for the maintained normal form.

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
