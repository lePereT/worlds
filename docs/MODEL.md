# Model

**Status: maintained explanatory model; `LAWS.md` is authoritative on conflict.**

## 1. Exact open causal incidence

A Worlds Geometry is a finite exact causal incidence structure with four carrier
kinds:

- **Membrane** — hierarchical locality/context;
- **Point** — exact identity appearing in Strand incidence;
- **Strand** — one exact scarce occurrence carrying an ordered Point tuple;
- **Face** — one causal transformation consuming and producing Strands.

Ingress and egress are derived from producer/consumer incidence. Worlds 0.6.3
does not claim that this raw structure is a conventional topological or cellular
2-complex.

## 2. Matching is a judgement over Geometry

The sacred operational ontology stops at exact Geometry and its open boundary.
Matching is a judgement over two ambient Geometries, not another kind of
Geometry and not a family of kernel modes.

Write:

```text
A ; B |- E match
```

when exact source egress occurrences in `A` lawfully realise the selected open
ingress pattern of `B`. The judgement respects ordered incidence, rigid imported
Point identity, target-local Point/Membrane substitution, endpoint locality and
exact source scarcity.

This distinction is real. `join({A,B},E)` may be defined for an equation set even
when `B` contains causal structure which is not a lawful executable development.
Matching therefore cannot be reduced to successful quotient materialisation.

## 3. Finite Questions

Finite judgement has two forms:

```text
Match(A,B;S,T,D,R,C,E0)
Close(P;S,T,D,R,C,E0)
```

Match is directional realisation of a target development from a source world.
Close is direct finite closure over ordered disjoint Geometry parts. `D` requires
source-domain coverage and `R` target-codomain coverage. Both carry exact finite
admissibility `C` and seeds `E0`; both expose the same evidence algebra.

Questions carry no authority and are not programme state. Every constructive
witness is checked against strict `join` before it is exposed.

`W.solve(A,B,seeds)` is the complete Match specialisation.

## 4. Replaceable query engine and epistemic result

The current engine compiles the source outgoing section into structural rows with
exact occurrence fibres, quotients target ingress by endpoint-thread locality,
factorises irreducible equality variables, proves scarcity with Hall matching and
only then enumerates exact Strand assignments.

Those structures are not semantic values. They live in `worlds.query_engine` and
may be replaced while the Question relation remains fixed.

The retained engine separates semantic result from incomplete computation:

- `yes` — one exact solution has been constructively produced;
- `no` — the finite Question is empty and exhausted;
- `more` — the configured fuel has not completed the calculation;
- `done` — at least one solution was emitted and all further alternatives have
  now been exhausted.

A retained engine state keeps only the exact source outgoing section required by
the Question, not closed source history.

## 5. join

`join(parts, equations)` is the one operation which changes Geometry.
Conceptually it performs:

```text
disjoint Geometry parts
+ directed equations between open occurrences
+ induced Point/Membrane equalities
+ causal SCC normalisation
+ frame-preserving materialisation
= resulting Geometry
```

The first part is the existing frame. Exact frame carriers unaffected by the
composition survive literally. Structure supplied by later parts is instantiated
where it is not identified with existing frame structure.

A causal cycle created by composition denotes mutual support and is represented
by one joint Face rather than a chosen serialisation. Its locality is the least
common enclosing Membrane of its participating Faces after locality equations.

## 6. Construction witness and Presentation

Geometry remains the sole composite value carrying programme authority and
causal structure.  0.6.3 adds two edge values around it.

A **Construction** is an immutable witness of one ordinary `join`
materialisation: its ordered parts, normalised equations, resulting Geometry and
exact carrier image.  The image is construction-relative identity transport; it
does not imply that endpoints produced by different materialisation paths have
literally identical carriers.

A **Presentation** is a finite ordered view of selected exact open Strand
occurrences relative to one ambient Geometry.  It owns no carrier and has no
causal force.  Presentation order and multiplicity may therefore express a
client-facing boundary convention without adding Points, Strands or Faces to the
programme.

A Presentation may be transported only through an actual Construction which has
its ambient Geometry as an exact part.  Coordinates are mapped pointwise through
the construction image and residualised to those images which remain open.
Transport does not invent authority.

This is deliberately weaker than a dimensional/ranked-complex API.  The current
research contains native face-free structures, higher coherence and inter-World
relations which are not yet captured by one production notion of rank.

## 7. boundary and live execution

`boundary(G)` projects exact history to the currently open causal frontier. It
keeps every exact egress occurrence plus only the owned Point/Membrane structure
needed to interpret those occurrences.

```text
historical Geometry
        |
     boundary
        v
live Geometry  -- solve --> equations
        |                     |
        +------ advance ------+
                  |
                  v
             live Geometry
```

Because `advance` immediately returns to `boundary`, persistent live state can be
bounded by frontier size rather than elapsed history.

## 8. Identity, equality and authority

Worlds exactness should not be confused with universal disequality. Imported
exact Points are rigid. Local ingress Points/Membranes are structural variables
and may be identified by solving when the Geometry permits it. Fresh downstream
structure becomes exact when materialised.

Likewise, knowing an exact Point or Membrane does not reveal or manufacture live
Strand authority. Causal use of existing local structure is validated through
input incidence.

## 9. Interpretation outside the kernel

The kernel deliberately does not decide domain-specific equality or dynamics.
For example, chemistry may quotient permutations of indistinguishable exact
reactants; a quantum model may attach amplitudes to alternatives; a logic may
restrict which explicit copy/drop Faces are admissible.

`speculation/` contains such experiments but is not semantic authority for the
release.
