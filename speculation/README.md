**Status: non-authoritative speculative experiments; excluded from Worlds semantic authority.**

# Speculation

This directory contains deliberately speculative experiments originally developed while pressure-testing Worlds 0.5.0, ported as a corpus to Worlds 0.6.0, and retained against Worlds 0.6.1. They are **not** part of the normative Worlds model, release law suite, or proof claims.

The experiments ask what happens when the same exact Point/Strand/Face/Membrane machinery is interpreted outside its original programming-semantics setting, and when some classical assumptions of the kernel are attacked directly.


## 0.6.0 port, retained in 0.6.1

The executable experiments now run against the authoritative 0.6 native kernel.
They do **not** load `compat/worlds.lua`. `speculation/support.lua` is a small
experiment-only harness over the public 0.6 operations:

```text
boundary -> Question -> solve -> advance
                          \-> join
```

It preserves a little mutable-boundary convenience for the historical experiment
code, but every solve/composition/evolution delegates to the public 0.6 Worlds APIs.
Restricted historical offer sets are expressed as Question `sources`, rather than
solving the complete boundary and post-filtering witnesses. Direct old `Cut.all`
counts were ported to native solve enumeration. The one old check of
`close` SCC metadata was dropped because 0.6 intentionally exposes only the
normalised Geometry; the corresponding joint-Face/boundary assertions remain.

Run all surviving executable experiments from the repository root with:

```sh
make speculation-check
```

## Quantum

### Quantum Theory over an exact Worlds geometry

- `quantum/worlds_quantum_bell_toy.lua` — Bell/CHSH toy: local Worlds causal authority with a non-separable joint quantum state and no-signalling marginals.
- `quantum/worlds_quantum_interference_toy.lua` — two-path interference, which-path records, coherent erasure, copied environmental records, and membrane-LCA support.
- `quantum/worlds_quantum_phase_boundary_falsification.lua` — attacks boundary sufficiency with hidden relative phase; distinguishes future-relevant relative phase from unobservable global phase.
- `quantum/worlds_quantum_contextual_boundary_test.lua` — finite contextual-equivalence/Nerode-style experiment; progressively richer X/Y/Z futures refine the semantic quotient until density-matrix equality is recovered.

### Quantising Worlds itself

- `quantum/worlds_quantised_kernel_toy.lua` — first kernel-level toy: superposed Cut witnesses, indefinite locality, superposed causal order, and failure of naïve linearisation of classical history-to-boundary projection.
- `quantum/worlds_quantum_kernel_explorations_4.lua` — actual Worlds Cut witnesses as a finite Quantum Cut operator; branch orthogonality/amplitude budget, quantised causal topology, and reference-relative fresh identity.
- `quantum/worlds_quantum_kernel_explorations_5.lua` — exact branch identity as a Stinespring/environment record; quotient-before-quantisation/gauge issues; global Gram/contraction condition `K†K ≤ I`.
- `quantum/worlds_quantum_kernel_explorations_6.lua` — fresh identity as nominal/gauge structure; same-vs-distinct identity as an observable relation; coherent relation mixing; fresh membrane topology.
- `quantum/worlds_quantum_kernel_explorations_7.lua` — finite permutation-gauge reduction; invariant subspaces; support-fixing stabilisers; same/distinct and co-local/split topology orbits.

Two intermediate scratch runs referred to in discussion as explorations **II/III** were not preserved as standalone files in the current workspace. Their main ideas were subsequently carried forward into the surviving experiments above: hard-core occupation/scarcity, projector-valued enabledness, linear no-cloning, membrane support subspaces, sum-over-injective-matchings/permanent-vs-determinant combinatorics, higher-dimensional trace quotienting, and a quantum frame-law toy. This README records that provenance rather than reconstructing source that no longer exists.

## Chemistry

- `chemistry/worlds_chemistry_toy.lua` — open compartmental reaction networks over exact scarce molecule authority. Exercises stoichiometric exact-solve scarcity, locality, transport, open composition, and the symmetry factor between exact ordered matchings and chemically unordered reaction opportunities.

The key deliberately exposed mismatch is that exact Worlds solve enumerates ordered exact reactant matchings, while ordinary chemical kinetics quotients permutations of indistinguishable reactant slots. This is treated as a domain symmetry, not silently repaired in the kernel.

## Logic

- `logic/worlds_linear_logic_toy.lua` — speculative multiplicative linear process skeleton: identity as continuity, solve/join as linear composition, juxtaposition, exchange, no free contraction, and no free weakening. It deliberately does **not** claim that MLL par, negation, exponentials, or a proof-net correctness criterion are already derived.

The experiment currently looks closer to a connective-free multi-input/multi-output process/polycategorical substrate than to a completed linear logic.

## Adversarial

- `adversarial/worlds_bodyline_tests.lua` — deliberately hostile tests developed after the speculative work. These attack the stronger extrapolations rather than the release contract: the unqualified “2-complex” description, retained naked Point references, factorial exact-witness symmetry, non-injective local Point/Membrane matching, overlapping context, raw-boundary minimality, SCC topology erasure, and scarcity-vs-conservation.

These tests are included here because several of the most useful corrections to the speculative models came from them.

## Status

All surviving Lua files in this directory were run successfully against the Worlds tree at the time this checkpoint was packaged. Passing these scripts means only that their internal assertions hold for their toy constructions. It does not promote their interpretations to Worlds laws or research results.
