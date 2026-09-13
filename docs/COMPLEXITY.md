# Complexity notes

Worlds does not make the general exact matching problem polynomial. Its intended
property is that work follows future-relevant geometry and the ambiguity of the
finite Question actually being asked.

## Geometry kernel

`boundary` and `join` operate only on exact Geometry. Long-running live state can
therefore remain proportional to frontier size rather than elapsed history.

The kernel contains no section planner, optional-target enumeration, factor graph
or scarcity search.

## Question preparation

A Question may select exact source/target sections. The public judgement is set-
based; the engine normalises presentation order before search.

The current engine caches the complete source outgoing section by exact source
Geometry and compiles smaller selected source sections directly. A retained
search stores that outgoing section, not closed source history.

## Egress lookup

The engine groups source egress by structural incidence and exact occurrence
fibres, with rigid Point-coordinate postings. Rigid coordinates can therefore
select candidate rows without scanning unrelated incidence.

## Target ingress quotient

Endpoint-thread equality is propagated only until the irreducible target boundary
requires it. A compressed boundary forest replaces raw ancestry as the variable
surface seen by factorisation.

Ancestry/depth/jump tables in the engine are disposable caches keyed by exact
Membrane identity; they are not Geometry semantics.

## Factorisation

Cost follows intermediate boundary width and row cardinality. Variable selection
minimises separator width first; factor join order favours shared variables. The
provenance DAG may still grow with genuinely distinct structural derivations.

## Optional targets

Targets in `T \\ R` are optional by Question definition. The present engine first
probes singleton feasibility, then enumerates feasible target subsets using the
ordinary complete matcher for each subset.

This is intentionally a reference-simple implementation of the Question
relation, not the intended final algorithm. A future engine can compile optional
support directly into the factor/provenance graph and eliminate the outer subset
enumeration without changing `Solutions(Q)`.

If `k` optional targets are genuinely independent, the Question itself may have
`2^k` distinct matched/unmatched target subsets. Output-sensitive exponential
behaviour is then unavoidable unless an observer explicitly quotients those
solutions.

## Exact allocation

Scarcity is output-sensitive. Hall feasibility rejects impossible structural
supports before exact enumeration, but requesting every exact permutation still
requires emitting every permutation.

## Admissibility

Mathematically `C` is a finite subset of `S × T`. The current public API accepts
an explicit exact relation. Future engines may compile equivalent representations
such as sparse rows, bitsets or partition constraints, provided they denote the
same finite `C` and remain Question implementation rather than Geometry.
