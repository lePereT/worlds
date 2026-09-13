# Research

**Status: non-authoritative research ledger.**

Worlds 0.6.0 intentionally keeps this file outside the semantic authority of
`LAWS.md`. These are questions suggested by the released kernel and by the
non-authoritative experiments in `../speculation/`.

## Mathematical classification

The raw Face/Strand causal skeleton is close to familiar occurrence-net and
monogamous acyclic open-hypergraph/string-diagram structures. Point substitution
has close neighbours in high-level Petri nets/Petri nets with identifiers;
individual exact Strand occurrences have neighbours in individual-token or
whole-grain Petri semantics; Membrane hierarchy has neighbours in bigraphical
and hierarchical graph/net formalisms.

The open question is therefore not whether every ingredient is unprecedented.
It is whether the complete calculus — exact structural fibres, hierarchical
locality equations, causal construction law, boundary solve and SCC/LCA join
normalisation — is equivalent to one established object or represents a useful
new factorisation/specialisation.

Concrete comparison targets:

- forget Points/Membranes and characterise the resulting open hypergraph;
- translate `solve` to modes/bindings of a high-level individual-token net;
- characterise the equality-closure part of `join` as a pushout or related
  universal construction if possible;
- determine whether SCC/LCA normalisation is a known reflection/transaction
  normal form or the genuinely distinctive part;
- compare commuting independent developments with occurrence/event/HDA notions.

## Membranes

Membranes currently form a forest with exact parent identity. They participate
both in structural matching and in the causal-construction law, and joint causal
support is placed at LCA after quotient.

Questions:

- Which laws truly require a tree rather than only a finite join-semilattice of
  contexts?
- Can overlapping contexts be added without destroying the small solve/join
  calculus?
- Is the right semantic interpretation locality, support, context bound, or a
  combination of these?
- Can the solve-induced Membrane mapping and join-induced Membrane quotient be
  characterised by a simple universal property?

## Semantic compression

A central research hypothesis is that familiar programming notions such as
ownership-like authority, conflict, concurrency, interface, generic
substitution, lifetime and live state are not independent kernel primitives but
derived views of exact open causal incidence plus structural solving and join.

This should be tested comparatively rather than asserted rhetorically: enumerate
which notions are primitive/derived/external in Worlds and neighbouring
formalisms, and prove the derivations where possible.

## Observational equality

Raw exact boundary is future-operational state, but 0.6 does not claim it is the
coarsest observational state. Fresh allocator choices, scheduler presentation
and domain symmetry can introduce distinctions an observer may not care about.

A later semantic layer may define support-sensitive contextual equivalence:

```text
X ~= Y  iff every lawful future observation gives the same result
```

and study full abstraction of concrete boundary/Theory representations against
that equivalence.

## Theory and domains

The kernel intentionally leaves domain interpretation external. Current
speculative pressure tests include quantum semantics, stochastic/chemical
reaction systems and resource-sensitive logic. Their purpose is to expose
missing kernel distinctions or unnecessary assumptions, not to make those
interpretations part of Worlds 0.6.0.

Particularly useful hostile domains include:

- overlapping biological/locality contexts;
- irreversible external effects and hardware I/O;
- distributed partial knowledge and failure;
- stochastic state and reaction symmetry;
- quantum coherence/indefinite causal alternatives;
- logics in which copy/drop permissions are derived rather than structural.

## Formalisation

The intended formal path is bottom-up:

1. finite Geometry and Membrane forest;
2. a simple declarative exact solve relation;
3. proof that factorised solve enumerates exactly that relation;
4. a declarative join quotient/normal form;
5. proof that DSU/SCC materialisation implements it;
6. boundary/advance theorems;
7. only then category/polycategory/open-graph correspondences.

No proof assistant or categorical identification is part of the 0.6.0 release
contract.
