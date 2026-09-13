# Theorem targets

**Status: theorem targets and executable evidence; not mathematical proofs.**

The implementation and tests are evidence. The intended formalisation should
state the declarative relations independently and prove the executable kernel
correct against them.

## T1 Geometry well-formedness

Builder output has unique producer/consumer incidence, acyclic Face causality,
exact ingress/egress and the stated causal locality/Point availability law.

Evidence: `tests/run.lua`, `tests/adversarial.lua`.

## T2 Boundary fixed point

`boundary(G)` preserves surviving carriers literally, contains no Face/closed
causal interior and is idempotent:

```text
boundary(boundary(G)) = boundary(G)
```

Evidence: `tests/run.lua`, `tests/history.lua`, live benchmark.

## T3 Matching judgement well-definedness

The declarative partial matching relation depends only on exact open incidence,
target causal-development structure and the induced equality/locality laws. It
is independent of presentation order and of any particular search algorithm.

Evidence: `tests/query.lua`, differential suites.

## T4 World-side boundary sufficiency

For a fixed target/question policy, replacing historical source Geometry by
`boundary(source)` does not change the exact matching solutions. A retained query
engine keeps the outgoing source section rather than closed source history.

Evidence: `tests/history.lua`, ordinary and selected-section differentials.

## T5 Ingress quotient correctness

The endpoint-thread quotient retains exactly the target Membrane equalities
needed by the matching judgement; proper-descendant equality is neither lost nor
leaked between sibling branches.

Evidence: adversarial, nested and branching differential suites.

## T6 Engine soundness and completeness

For every finite Question `Q`, the factor/provenance/Hall engine emits exactly
`Solutions(Q)`: every `yes` is a lawful exact match satisfying `S,T,R,C,E0`, and
every such exact solution is eventually enumerated.

Evidence: `tests/differential.lua`, `tests/restricted-differential.lua`,
`tests/partial-differential.lua`, nested/branching differentials.

## T7 Search epistemics

Finite fuel exhaustion can yield only `more`, never semantic `no`. `no` is
returned only after exhaustive emptiness of one exact finite Question; `done`
only after exhaustion following one or more emitted solutions.

Evidence: native tests and the shape guard.

## T8 join congruence and frame preservation

Supplied open-boundary equations generate the implemented typed equality closure
on Strands/Points/Membranes. Unaffected carriers from the first part survive
literally in the result.

Evidence: native tests plus `tests/historical/close_link_laws.lua` and related
historical algebra cases through `compat/worlds.lua`.

## T9 Mutual-support normalisation

The causal quotient of a cyclic SCC is one joint Face, the condensation is
acyclic, and external open boundary is preserved.

Evidence: `tests/historical/symmetric_close_cycle_joint.lua`,
`joint_scc_preserves_external_boundary.lua`, `multiple_joint_sccs.lua`.

## T10 Joint locality

A joint Face resides at the least common enclosing Membrane of the member Faces
after induced Membrane equations.

Evidence: `tests/historical/cross_locality_joint_lca.lua`,
`joint_scc_order_and_lca.lua`.

## T11 advance/history commuting result

`advance(world, development, equations)` is exactly boundary projection of the
ordinary join with `boundary(world)`. Optional `worlds.history` records that
transition without changing future kernel behaviour.

Evidence: definition of `advance`, `tests/history.lua`.

## T12 Presentation-order invariance

Non-semantic presentation choices — compatible equation-family order and Face
input/output enumeration order — do not change external causal result except for
fresh occurrence correspondence where exact materialisation differs.

Evidence: historical algebra suite.

## T13 Question normal-form completeness

Selected-source queries, selected-target queries, optional targets, explicit
admissibility restrictions and exact seeds are all instances of the single
Question normal form `Q=(A,B,S,T,R,C,E0)` rather than distinct solve semantics.
The public engine agrees with brute-force finite relation enumeration on the
maintained generated suites.

Evidence: `tests/query.lua`, `tests/restricted-differential.lua`,
`tests/partial-differential.lua`.

## Longer-term theorem programme

Formal work should separate:

1. a mechanised declarative partial matching judgement and finite Question relation, separated from the factorised/Hall engine;
2. a declarative quotient/normal-form `JoinSpec` from DSU/SCC materialisation;
3. exact raw Geometry equality from any later support-sensitive observational
   quotient.
