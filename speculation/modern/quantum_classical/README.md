# Quantum-to-classical emergence experiments over Worlds 0.6.2

**Status: non-authoritative research experiments.** These files modify neither
Worlds nor Relay. They use only Lua/TeX Lua and the unchanged Worlds 0.6.2 API;
there are no Python, SymPy, CAS or external numerical dependencies.

Run with the repository speculation corpus:

```sh
make speculation-check
```

The programme deliberately asks a different question from the earlier quantum
attacks. Rather than asking how to add quantum ontology to Worlds, it asks
whether recognisably classical semantics can arise as fixed points, quotients,
coarse-grainings or asymptotic sectors of a quantum interpretation over
structures Worlds already has.

## Results

### 1. `boundary_trace_decoherence.lua`

A system and environment are entangled by an ordinary causal Face. The
environment authority is then consumed and becomes absent from the live Worlds
boundary. Quantum Theory projects the joint Bell-like state to the surviving
system by partial trace, producing exactly the dephased mixture

```text
1/2 |0><0| + 1/2 |1><1|.
```

If the entanglement is coherently uncomputed before the environment is hidden,
the same one-system causal interface instead retains the original `|+>`
coherence. Thus causal hiding and quantum projection can interact nontrivially:
`boundary` identifies what survives operationally; Theory determines what state
survives extensionally.

### 2. `classical_stochastic_sector.lua`

Dephasing `Delta` is idempotent. Its fixed states are diagonal density matrices,
which are exactly ordinary probability vectors. Bit-flip and amplitude-damping
quantum channels commute with this classicalisation and restrict to stochastic
matrices; sequential Worlds Faces therefore restrict from quantum channel
composition to ordinary Markov composition.

The experiment also constructs a CPTP channel for each of several arbitrary
2-state stochastic matrices using Kraus operators

```text
K[j,i] = sqrt(P[j,i]) |j><i|.
```

So the classical stochastic theory sits concretely inside quantum channel
semantics over the same causal process shapes.

### 3. `copyable_classical_structure.lua`

Worlds can explicitly split one exact authority into two fresh occurrences; it
never obtains duplication implicitly. Quantum Theory interprets that shape with

```text
Delta|0> = |00>
Delta|1> = |11>.
```

`Delta` satisfies coassociativity, cocommutativity, counit and specialness, while
`|+>` is not cloned. This is a small internal classical copying algebra: the
classical basis is characterised by the quantum states on which the explicit
copy geometry actually acts as copying.

### 4. `einselection_basis.lua`

A system-environment recording interaction induces an idempotent dephasing
channel. CNOT interaction selects the Z basis as its fixed/copyable pointer
states. Conjugating the interaction by Hadamards selects the X basis instead.
The Worlds process geometry is unchanged; the classical subalgebra is selected
by quantum interaction semantics rather than hard-wired into the kernel.

### 5. `darwinism_membranes.lua`

One system Point interacts with four environment fragments in disjoint membrane
subtrees. The causal event produces four exact record Strands, each local to a
different membrane and each structurally referring to the same persistent
system identity.

The quantum state is a five-qubit GHZ state. Every individual environment
fragment carries one full classical bit about the pointer value, while the
relative global GHZ phase is invisible to every proper fragment. Consuming one
exact record leaves the other membrane-separated records literally intact.
This gives a concrete Worlds notion of redundant, independently available
classical record without cloning an arbitrary quantum state.

### 6. `contextual_classical_islands.lua`

The Mermin-Peres square is built from actual two-qubit quantum operators. The six
commuting contexts are represented as overlapping face-free Point-Strand scopes.
For each context the quantum operator product derives a +/-1 parity law, and the
context therefore has an ordinary four-element classical outcome space.

All six local classical spaces are sound, but there is no global +/-1 assignment
to the nine shared observables. Removing any one context restores 16 global
assignments. Classicality therefore appears locally by restriction to commuting
subtheories; contextuality is exactly an obstruction to gluing those local
classical interpretations into one global one.

### 7. `decoherent_history_measure.lua`

Three exact causal histories are given a finite decoherence functional. Fine
coherent histories do not obey ordinary additive probability. Once one boundary
class decoheres from another, the coarse-grained classes obey finite Kolmogorov
additivity even though interference remains inside one class. Refining until all
histories decohere gives an ordinary probability distribution over exact
histories.

This is the cleanest toy of `classical probability = decoherent quotient of
quantum exact histories`.

### 8. `hom_classicalisation.lua`

Two exact two-particle exchange histories lead to the same unlabeled detector
boundary. Their balanced-beam-splitter coincidence amplitudes `+1/2` and `-1/2`
cancel, giving Hong-Ou-Mandel suppression. If exact particle identity is retained
in the open boundary, those histories become distinguishable and their
probabilities add to the classical 50% coincidence rate.

Exact individuality was present in Worlds throughout. The quantum/classical
transition is whether the distinction remains observable and coherent, not
whether particles acquire identity.

### 9. `path_sum_determinism.lua`

Two Hadamard stages have two hidden exact route histories for every classical
input/output bit. Summing amplitudes over the hidden route gives exactly the
identity transition: classically forbidden outputs cancel and allowed outputs
add to unit amplitude. Destroying route coherence instead gives a 50/50
stochastic output.

This is an exact finite example in which deterministic classical dynamics is a
coherent quantum path-sum result rather than a property of any individual path.

### 10. `stationary_phase_histories.lua`

Representative exact Worlds histories differ only in a hidden intermediate
position and share the same surviving boundary. A dense dependency-free
quadrature then evaluates a free-particle-style action

```text
S(x) = x^2/1 + (1-x)^2/3
```

whose stationary point is `x*=1/4`, the classical straight-line position at the
intermediate time. As action/hbar grows, non-stationary contributions cancel and
the path sum approaches the standard stationary-phase contribution around
`x*`. This is deliberately only a finite numerical toy, but it shows a plausible
route by which a classical least-action history can emerge from coherent sums
over exact causal constructions.

## Synthesis

The experiments expose several distinct meanings of “classical limit”, all over
the unchanged Worlds kernel:

```text
quantum state
    | environment + hiding
    v
idempotent decohered fixed sector
    |
    +--> probability states and stochastic dynamics
    |
    +--> copyable pointer data
    |
    +--> redundant membrane-separated records

quantum exact histories
    | decoherent observational quotient
    v
classical probability measure

commuting quantum contexts
    | restriction
    v
local classical sample spaces
    | contextual gluing may fail

coherent path family
    | destructive interference / stationary phase
    v
classically deterministic or least-action behaviour
```

The recurring Worlds contribution is not a special quantum carrier. It is the
availability of exact histories, scarce occurrences, persistent identities,
overlapping Point-Strand scopes, membrane-separated records, causal hiding and a
boundary notion against which quantum Theory can define coherence or
indistinguishability.

## Important negative lesson

The experiments do **not** show that classicality is merely `boundary(G)`, that
Worlds derives the Born rule, that decoherence alone solves the measurement
problem, or that the stationary-phase toy constitutes a derivation of classical
mechanics. They show that several standard routes from quantum to classical
structure can be stated unusually cleanly using distinctions already forced by
Worlds for non-quantum reasons.
