# Theorem targets

**Status: theorem targets and executable evidence; not mathematical proofs.**

The implementation and tests are executable evidence, not mathematical proofs.
The formal programme should attack these claims directly.

## T1 Frame preservation

A development consuming exact authority `C` preserves every unrelated egress
Strand occurrence exactly.

Evidence: `tests/authority/frame_law.lua`,
`tests/cut/unrelated_commit_preserves_witness.lua`, structural benchmarks.

## T2 History/boundary commuting square

For every admissible complete Cut, exact closure then egress projection agrees
with specialised operational execution up to the occurrence image of the
process.

Evidence: `tests/state/history_boundary_commuting_square.lua`,
`tests/state/fresh_identity_history_boundary.lua`, `tests/torture/whole_model.lua`.

## T3 Cut-family coherence

The normal form of one compatible simultaneous Cut family is independent of
presentation order.

Evidence: `tests/algebra/cut_family_order_invariance.lua`,
`tests/algebra/joint_scc_order_and_lca.lua`.

## T4 Tensor symmetry and composition associativity

Juxtaposition is permutation-invariant up to exact renaming.  Acyclic wiring
has the same external boundary and causal shape independent of construction
parenthesisation.

Evidence: `tests/algebra/cut_associativity.lua`,
`tests/algebra/close_link_laws.lua`, generated whole-model torture.

## T5 Boolean cube independence

`n` mutually independent exact developments induce the Boolean `n`-cube.
Competing scarce developments do not complete the corresponding higher cell.

Evidence: `tests/concurrency/cube_compatibility.lua`, including all 120 complete
5-cube linearisations.

## T6 Mutual-support normalisation

A closed causal support SCC is one indivisible joint occurrence and the SCC
condensation remains acyclic.

Evidence: symmetric/joint SCC algebra tests and structural ring benchmark.

## T7 Joint locality

A joint occurrence resides at the least common enclosing membrane after
cut-induced membrane equations.

Evidence: LCA algebra tests and generated support rings.

## T8 Identity is not authority

Point/Membrane identity and structural compatibility alone cannot authorise
modification of existing locality.

Evidence: `tests/authority/`.

## T9 Boundary-sufficient Theory

Any Theory which controls future development decides from current/open candidate
semantics.  Historical fact must be carried forward explicitly if it matters.

Evidence: `../tests/theory/`, `../archaeology/THEORY_PORT.md`; this remains a constitutional target
for arbitrary external Theory implementations.

## T10 Structural work

Correctness never depends on wall-clock time.  Release tests assert candidate
steps and semantic shape rather than elapsed time.

## Face-incidence permutation invariance

Permuting only the presentation order of the distinct input Strands of a Face,
or only the presentation order of its distinct output Strands, does not change
the semantic open process.  In particular, joint-SCC normalisation is invariant
under Face-incidence, tensor-factor and Cut-family presentation order.

Positional meaning belongs in ordered Strand Point incidence or Theory.
