# Quantum/classical correspondence — early work

**Status: non-authoritative research note for Worlds 0.6.2.**

This note records an unexpectedly strong line opened by the 0.6.2 incidence
programme. It changes no kernel law, public API or implementation and makes no
claim to solve the measurement problem, derive the Born rule or establish a
physical interpretation of Worlds.

The deliberately large conditional is this:

> If a compositional quantum semantics can be given over ordinary Worlds
> structures, perhaps recognisably classical Worlds semantics is not a second
> interpretation placed alongside it, but a stable fixed, quotient, decohered,
> copyable or asymptotic regime *inside* it.

The interest of that possibility is explanatory. Scarcity, exact occurrence,
copyability, locality, boundary and classical probability would then not have to
be introduced independently on the classical and quantum sides. Some of the
structures which make Worlds useful as an ordinary computational kernel might
reappear as the classical behaviour of a richer semantics over the same exact
geometry.

## 1. Several classical limits, not one

The current experiments do not suggest a single operation called
"classicalisation". They expose several distinct but compatible mechanisms:

```text
quantum state
    | environment interaction + projection
    v
idempotent decohered fixed sector
    |
    +--> ordinary probability states
    +--> stochastic / Markov dynamics
    +--> copyable pointer data
    +--> redundant independently available records

quantum exact histories
    | decoherent observational quotient
    v
ordinary additive probability

commuting quantum contexts
    | restriction
    v
local classical sample spaces
    | gluing may fail
    v
contextual obstruction to one global classical interpretation

coherent exact histories
    | interference / stationary phase
    v
classically deterministic or least-action behaviour
```

These mechanisms need not coincide in a general system. Their possible
compatibility is itself a research question.

## 2. Boundary and quantum projection

Worlds already separates exact causal interior from the live open boundary.
The experiment `boundary_trace_decoherence.lua` pairs that structural hiding
with ordinary quantum partial trace.

When a system becomes entangled with an environment which is subsequently
causally internal, the surviving Worlds interface can be the system alone while
quantum Theory assigns it the reduced, dephased mixed state. If the interaction
is coherently uncomputed before the environment becomes internal, the same
one-system interface retains coherence.

This does **not** identify `boundary(G)` with decoherence. It suggests a more
careful correspondence:

```text
boundary     determines which exact authority remains operationally exposed
Theory       determines the extensional state induced on that surviving scope
```

A serious formulation should ask when quantum projection is functorial with
Worlds composition and when it commutes with boundary restriction.

## 3. Classical probability as a fixed subtheory

For a dephasing channel `Delta`,

```text
Delta(Delta(rho)) = Delta(rho).
```

Its fixed states are diagonal density matrices, hence ordinary finite
probability vectors. Quantum channels preserving that fixed sector restrict to
stochastic matrices, and sequential quantum composition restricts to ordinary
Markov composition.

The experiments also construct quantum channels realising representative
finite stochastic maps. The research target is therefore stronger than
"classical probabilities can be encoded quantum mechanically":

```text
Quantum(Worlds)
      |
      | fixed/restricted sector
      v
Classical stochastic process semantics
```

A useful future theorem would identify conditions under which such a sector is
closed under Worlds composition, boundary and relevant Theory projection.

## 4. Classical data as the copyable sector

Worlds never obtains duplication of scarce authority implicitly, but it may
represent an explicit split/correlation Face. Quantum semantics can certify
that this shape copies a preferred basis while refusing to clone arbitrary
superpositions.

Thus the same Geometry can support both:

```text
basis state     explicit split behaves as copying
superposition   explicit split produces entanglement instead
```

This makes "classical data" a possible *property of a quantum subtheory* rather
than a new carrier kind. The environment-selection experiment sharpens the
point: different interactions select different fixed/copyable pointer bases
without changing Worlds Geometry.

## 5. Objective record as exact redundancy

The membrane experiment creates several exact record Strands in disjoint
membrane subtrees, all structurally referring to one persistent system identity.
Each fragment can carry the same classical pointer information while global
quantum phase remains inaccessible to every proper fragment.

This suggests a concrete structural criterion worth investigating:

```text
objective classical record
    ~ copyable information
      + many exact record occurrences
      + distribution across sufficiently independent causal supports
      + stability under local reading/consumption
```

The exact occurrences remain causally individual. Their redundancy is not an
identification in the kernel.

## 6. Classicality may be local before it is global

The Mermin-Peres experiment uses actual commuting quantum contexts over six
overlapping Point-Strand scopes. Each context yields an ordinary finite
classical outcome space. The six local classical interpretations are sound but
cannot be glued into one global valuation.

This suggests a useful reversal of emphasis:

> Quantum theory need not lack classical interpretations. It may contain many
> local classical subtheories, with contextuality measuring the obstruction to
> one global classicalisation.

Point-Strand incidence is a natural carrier of the overlapping scope because it
permits arbitrary sharing without turning compatibility into causal succession
or forcing crossing membrane hierarchies.

## 7. Exact histories and observational quotients

Worlds preserves exact construction history more finely than many observations
do. The interference and Hong-Ou-Mandel experiments exploit this distinction:
several exact histories can remain causally distinct while falling into one
observational boundary class.

Quantum semantics may then combine amplitudes before squaring. If exact records
survive which distinguish those histories, their probabilities instead add at
that observational resolution.

This suggests the schematic object:

```text
exact Worlds histories H
        |
        | observational/coarse boundary map
        v
boundary classes B

quantum semantics: amplitudes/decoherence functional on H
classical sector: additive probability measure on suitable classes in B
```

The important claim is not that Worlds query witnesses are quantum branches.
Questions remain epistemic and non-authoritative. The candidate object is a
mathematical family of lawful exact constructions and a chosen observation of
their surviving boundaries.

## 8. Classical dynamics from quantum path structure

Two deliberately radical experiments probe dynamics rather than static data.

First, a two-stage Hadamard process contains two hidden route histories for each
input/output pair. No individual route is a deterministic classical law, but
coherent path summation cancels the disallowed outputs and yields the deterministic
identity map exactly. Destroying route coherence gives a stochastic 50/50 map.

Second, a dependency-free numerical stationary-phase toy sums phases over exact
histories distinguished by one hidden intermediate coordinate. As action/hbar
increases, non-stationary contributions cancel and the sum approaches the
stationary contribution around the classical least-action intermediate point.

The latter is deliberately weak evidence: it is a finite numerical analogy, not
a path-integral construction or derivation of classical mechanics. Its value is
that Worlds already supplies an exact notion of alternative causal construction
and surviving boundary on which a future rigorous history semantics could be
stated.

## 9. Identity and indistinguishability

The fibre and Hong-Ou-Mandel experiments suggest that exact individuality and
physical indistinguishability need not compete.

Worlds can retain exact scarce occurrences for causal accounting while quantum
Theory carries permutation symmetry or antisymmetry over the structural fibre.
Whether exact particle identity remains observable at the boundary can change
the statistics without requiring identity to appear or disappear from the
kernel.

A future comparison target is therefore a representation/groupoid semantics over
exact Strand fibres, not a kernel quotient which erases exact authority.

## 10. A possible emergence ladder

The current speculative synthesis is:

```text
quantum semantics over exact Worlds processes
        |
        | interaction + hiding / coarse observation
        v
decoherent fixed or quotient sectors
        |
        +--> probability states + stochastic maps
        |
        +--> copyable pointer information
        |        |
        |        +--> redundant membrane-separated records
        |                  |
        |                  v
        |           stable objective classical facts
        |
        +--> local commutative/classical contexts
                 |
                 +--> may or may not glue globally

coherent exact histories
        |
        +--> interference can yield deterministic laws
        +--> stationary phase may select classical trajectories asymptotically
```

The provocative possibility is that ordinary classical process semantics may be
recoverable as a dynamically selected regime of a quantum semantics over the
same exact structural substrate.

## 11. Why this would matter

If the large conditional survived, Worlds would no longer be interesting merely
because it can encode classical and quantum examples. It would be a candidate
**intensional process substrate** sitting before the choice of classical or
quantum semantics.

That would place the formalisation programme near several established families
without identifying Worlds with any of them:

- symmetric-monoidal and categorical quantum process theories;
- classical stochastic / Markov process theories;
- open-system, cospan and wiring-diagram calculi;
- linear-resource and proof-net semantics;
- sheaf/descent accounts of contextuality;
- decoherent/consistent histories;
- occurrence/event structures and concurrency semantics;
- nominal/dependent systems for exact identity and freshness.

The potentially distinctive contribution would be the simultaneous presence of
exact occurrence identity, scarce authority, persistent structural identity,
hierarchical causal support, open boundary, frame-preserving materialisation and
construction-relative identity transport beneath several semantic regimes.

This is a comparison programme, not a priority claim or an assertion that these
formalisms reduce to Worlds.

## 12. Falsifiers and proof obligations

The correspondence should be abandoned or narrowed if the following repeatedly
fail:

1. **Compositional quantum semantics.** Sequential join/advance and independent
   juxtaposition must admit coherent quantum interpretations beyond tiny matrix
   examples.
2. **Locality.** Local intervention must not require spurious non-local causal
   authority. The current hostile test already warns against representing a
   global extensional quantum state as one scarce joint Strand merely for
   convenience.
3. **Boundary compatibility.** Quantum restriction/projection on surviving
   scope must compose predictably with Worlds boundary; `boundary` itself must
   not be mistaken for physical decoherence.
4. **Classical closure.** Proposed fixed/copyable sectors must be closed under
   the process operations claimed to be classical.
5. **Exact versus observational identity.** Coarse observational quotients must
   never silently erase exact authority needed by later causal composition.
6. **Contextuality.** Any alleged global classicalisation must preserve known
   obstructions rather than smuggling in a global valuation.
7. **Asymptotic dynamics.** Stationary-phase evidence must eventually be stated
   over a principled family/refinement of histories, not hand-selected numerical
   samples.
8. **No ontology inflation by semantics.** Rich quantum mathematics alone is not
   evidence for a fifth carrier. A kernel extension requires a genuinely new
   distinction in exact operational identity or causal permission.

## 13. Executable evidence

The principal experiments are under:

```text
speculation/modern/quantum_atlas/
speculation/modern/quantum_classical/
```

The first attacks quantum phenomena through structures already identified in the
incidence atlas: contextual overlap, exact occurrence fibres, alternative exact
histories, transport phase, copyability, compositional process semantics and a
hostile locality case.

The second asks directly how recognisably classical structure can arise from a
quantum interpretation: boundary/partial-trace decoherence, stochastic fixed
sectors, copyable algebras, environment-selected pointer bases, redundant
records, local classical contexts, decoherent-history probability,
distinguishability, deterministic path sums and stationary phase.

All experiments are dependency-free Lua/TeX Lua. They call no Python, SymPy,
CAS or external numerical package. Where a non-trivial expected mathematical
relation is required, it is checked against an explicit pre-determined relation
or computed by small local arithmetic inside the test.
