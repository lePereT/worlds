# Shape of Worlds 0.6.0 after the query split

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

Geometry is the sole composite semantic value. Exact carrier identity and open
incidence are authoritative.

## 2. Finite Question judgement

`src/worlds/query_factory.lua` defines the immutable Question normal form:

```text
Q = (A,B,S,T,R,C,E0)
```

It validates exact finite sections and relations, but contains no factor solver,
Hall matcher or search strategy.

A Question is not Geometry and carries no authority.

## 3. Replaceable query engine

`src/worlds/query_engine.lua` implements the matching judgement efficiently. Its
current representation contains:

- counted source incidence rows and exact fibres;
- endpoint-thread target quotient;
- compressed target boundary forest;
- factor relations with AND/OR provenance;
- Hall feasibility; and
- one exact allocator.

These structures are disposable. The source Geometry is not retained after
compilation; only the selected outgoing section survives in retained search
state.

## 4. join

`join` remains the single typed-equality and causal-normalisation operation.
Matching and materialisation are deliberately distinct: successful `join` does
not by itself prove that an equation set satisfies the target matching judgement.
