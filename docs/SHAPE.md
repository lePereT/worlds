# Shape of Worlds 0.6.3

## 1. Sacred Geometry kernel

`src/worlds/_kernel.lua` contains the operational ontology:

```text
Membrane
Point
Strand
Face
Geometry
boundary
join
advance
```

It contains no matching engine or acceleration dependency. The public
`src/worlds.lua` edge adds `solve(A,B,seeds)` as the complete-Question
convenience and may eagerly prepare disposable indexes for Builder output. No
selected-section, optional-target, admissibility, factorisation or scarcity-
search policy is represented in the verified centre.

Geometry is the sole composite value carrying programme authority and causal
structure. Exact carrier identity and open incidence are authoritative.

## 2. Finite Question judgement

`src/worlds/query_factory.lua` defines immutable exact Questions in two forms:

```text
Match(A,B;S,T,D,R,C,E0)
Close(P;S,T,D,R,C,E0)
```

It validates finite sections/relations and guarantees that every public `yes(E)`
is accepted by strict `join(question:parts(),E)`. It contains no factor solver,
Hall matcher or direct-closure enumeration strategy. A Question is not Geometry
and carries no authority.

## 3. Replaceable query engine

`src/worlds/query_engine.lua` implements the matching judgement efficiently. Its
current representation contains:

- counted source incidence rows and exact fibres;
- endpoint-thread target quotient;
- compressed target boundary forest;
- factor relations with AND/OR provenance;
- Hall feasibility; and
- one Geometry-free finite scarce-relation solver shared by Match and Close.

These structures are disposable. The source Geometry is not retained after
compilation; only the selected outgoing section survives in retained search
state.

## 4. join

`join` remains the single typed-equality and causal-normalisation operation.
Matching and quotient construction are deliberately distinct: successful `join`
does not by itself prove that an equation set satisfies the target matching
judgement, while every constructive Question witness is guaranteed join-lawful.

## 5. Semantic edge values

`src/worlds/construction.lua` and `src/worlds/presentation.lua` sit outside the
verified centre and outside the replaceable query engine.

`worlds.construction` calls the ordinary public `join` exactly once and retains
its ordered parts, normalised equations, result and exact image in immutable
private state. It owns no quotient or matching algorithm.

`worlds.presentation` stores only an exact ambient Geometry plus copied arrays of
selected open Strand references. Its sole derived operation is residual transport
through a `worlds.construction` value. It cannot create or consume Geometry.

The main `require('worlds')` facade does not import or re-export either module.
Clients opt into these edge values explicitly.
