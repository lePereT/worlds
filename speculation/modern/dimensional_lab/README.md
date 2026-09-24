# Cross-domain dimensional laboratory

This folder is intentionally temporary and cross-domain.  Nothing here proposes
new kernel carriers or public API.  The point is to test whether the W1/W2/W3
patterns found while studying boundary reducts recur independently in domains
which do not care about programming-language callability.

The experiments use three disciplines:

1. exact W2 histories remain distinct even when a domain regards their exposed
   boundary as equivalent;
2. higher deformation geometry carries an explicit graded lift back to those W2
   histories rather than pretending that bare higher Geometry remembers source
   rank; and
3. domain semantics (phase, action, stoichiometry, logical formula meaning) stays
   outside Geometry.

All focused experiments currently pass: 247 assertions across twelve pressures.
The complete Worlds speculation corpus and maintained `full-check` also pass with
this folder present.  Production `src/`, maintained tests and normative docs are
unchanged.

## Current bearings

The strongest cross-domain conclusion is *not* a simple tower
`W2 -> W1 -> W0` or `W3 -> W2 -> ...` in which every lower or higher object is
canonically derivable from its neighbour.

Two negative results matter:

- the Mermin-Peres compatibility cover is already a lawful intrinsic face-free
  incidence world.  Exact boundary reduction of that cover is strictly richer:
  it adds exact occurrence coordinates while containing the contextual scope as
  a canonical structural projection;
- the same family of exact W2 histories admits several inequivalent lawful
  higher deformation graphs (path, cycle, complete graph).  Higher adjacency is
  therefore additional structure chosen by the domain, not reconstructible from
  the W2 histories or their common W1 boundary alone.

The more plausible picture is a *stratified incidence calculus* with native
objects at several ranks plus exact relative lifts/transport between ranks.

A recurring pattern is:

```text
W1-like structural incidence
    compatibility / exposed scope / stoichiometric boundary

W2 causal incidence
    exact processes / histories / reaction mechanisms / proofs

W3-like structural incidence
    neighbourhood / deformation / coherence among exact W2 histories

W3 causal incidence (when genuinely required)
    directed refinement/rewrite between W2 histories
```

Face-free relation and causal rewrite are deliberately distinct at the higher
rank, just as structural interface and causal execution are distinct below.

## Quantum pressures

### `quantum/contextual_cover.lua`

The Mermin-Peres compatibility cover is lawful face-free Point-Strand incidence
in its own right.  Each observable occurs in two crossing contexts.  A full
exact-occurrence reduction adds one carrier coordinate per context occurrence;
removing only that leading exact-fibre coordinate recovers the original
contextual rows and their shared observable Points exactly.

This argues against defining W1 merely as "the image of reducing W2".  There are
intrinsic W1-like configurational worlds; a W2 reduct may be an exact-occurrence
enrichment over such a configuration.

Causally thickening every context into a measurement Face adds still more
collar information and is not the compatibility cover itself.

### `quantum/interference_resolution.lua`

Which-path authority refines the reduced exposed scope from
`[exact-port,q]` to `[exact-port,q,record]`.  A real W2 erasure Face removes the
record and the resulting W1 structure coarsens again.  The unmarked direct route
and marked-then-erased route expose the same observational boundary while
retaining different exact W2 histories.

Thus observational resolution can be structural at W1 while the act which
changes that resolution remains genuinely causal at W2.

### `quantum/path_variation.lua`

Several exact two-segment W2 paths with one external boundary become Points in a
face-free higher deformation neighbourhood.  External action Theory has a
stationary history precisely relative to that higher adjacency.  Symmetric
finite variations at successively smaller scales have zero centred first
variation and the expected second variation.

The higher geometry supplies *which histories are neighbours*; action remains
Theory.  Stationary phase therefore has a natural W3-like formulation without
making numerical physics part of Geometry.

### `quantum/higher_holonomy.lua`

Four exact W2 histories form a face-free higher deformation loop.  U(1)-like
phase values on deformation edges transform under vertex rephasing, while the
closed-loop sum is invariant.  Three edge phases can be gauged away and the
remaining edge carries the total holonomy.

This gives higher history space a genuinely geometric use: loops among exact
histories support domain Theory invariants.

## Chemistry pressure

### `chemistry/mechanisms.lua`

Two exact two-step mechanisms (`2A+B -> C -> E` and `2A+B -> D -> E`) and a
one-step net reaction (`2A+B -> E`) have the same stoichiometric W1-like boundary
while retaining different W2 causal interiors.

Exact boundary reduction keeps the two A occurrences distinct; the coefficient
2 is multiplicity of scarce occurrences rather than one weighted carrier.

A face-free higher mechanism atlas relates the three exact surfaces without
identifying them.  Direct coarse-graining of the C mechanism to the net reaction
and staged C->D->net coarse-graining have the same higher source/target boundary
but remain exact-distinct higher histories.

This reproduces the process/refinement pattern without programming concepts.

## Logic pressures

### `logic/cut_coherence.lua`

Two independent cut chains constructed simultaneously, left-first, or
right-first retain exact construction history but expose one logical sequent.
Their permutation is represented by face-free higher coherence incidence rather
than a new W2 proof rule.  Direct and staged coherence paths stay exact-distinct.

### `logic/three_cut_permutohedron.lua`

Three independent cuts have six construction orders.  All expose the same
sequent and retain six exact W2 histories.  Adjacent permutations form a
six-vertex/six-edge face-free S3 permutohedron.

The two braid routes

```text
s1 s2 s1
s2 s1 s2
```

from order 123 to 321 become two exact three-Face higher histories with the same
higher boundary.  This is a particularly clean non-programming example of
coherence one rank above exact process history.

## Domain-neutral controls

### `neutral/process_interchange.lua`

Monoidal interchange gives several exact-distinct W2 construction histories with
one exposed process interface.  A face-free higher atlas relates them without
causality.  Directed higher rewrites can also be formed when causal/refinement
semantics is deliberately wanted; direct and staged higher rewrites are not
identified.

### `neutral/fibre_symmetry.lua`

One exact structural fibre with three scarce occurrences gives all 3! exact
allocations.  The same Geometry supports two independent domain readings:

- chemistry quotients by identical-slot automorphisms and sees one unordered
  allocation class;
- quantum Theory may carry the trivial character (sum 6) or sign character
  (sum 0).

Exact scarcity is retained in every case.  This is strong evidence that exact
fibre geometry is domain-neutral and quotient/representation semantics belongs
in Theory.

### `neutral/higher_cycle_theories.lua`

One face-free four-history deformation cycle supports several independent
Theories without changing Geometry:

- U(1)-style phase holonomy;
- stochastic/thermodynamic log-rate cycle affinity;
- a Z2/sign loop product.

In each case a vertex gauge/reference change cancels around the cycle.  This is
the higher-rank analogue of earlier `theory_algebras` pressures: Geometry supplies
incidence, Theory supplies the algebra.

### `neutral/higher_scc_shadow.lua`

Ordinary Worlds is interpreted one rank up as a hostile control.  Cyclic higher
rewrite families of sizes 2 through 6 contract to one joint event with their
external higher ingress/egress preserved.  One further full-incidence descent is
face-free and structural.  Repeating the experiment with deliberately
quantum-like, chemistry-like and logic-like labels makes no difference.

So the SCC shadow law is incidence-driven rather than domain-driven.

### `neutral/higher_non_derivability.lua`

Four exact W2 histories with identical exposed boundaries admit a three-edge
path atlas, four-edge cycle atlas and six-edge complete atlas.  All are lawful;
none is selected by the W2/W1 data.

Separately, two higher geometries with the same local one-row shape can have
opposite lifts to the W2 source histories.  Bare higher Geometry therefore does
not recover source rank/meaning.  An exact graded lift remains essential one
rank up, matching the lower-rank falsifiers from the boundary-reduct programme.

## Emerging cross-domain laws

The experiments currently support these hypotheses.

### 1. Incidence rank is more fundamental than "derived world"

W1-like configurational structures can exist intrinsically.  W3-like deformation
structures can be additional structure over W2 histories.  Reduction and
thickening relate ranks, but do not exhaust the objects which can live at a rank.

### 2. Exact history should survive equivalence/coherence

Across process interchange, chemistry mechanisms and logic cut orders, exact W2
histories remain distinct even when they share a domain boundary.  Higher
incidence expresses relationship without destructive quotienting.

### 3. Structural relation should not be causally thickened by default

A face-free deformation edge/cover is enough for contextual compatibility,
path neighbourhood, interchange adjacency and proof coherence.  A higher Face is
reserved for a genuinely directed refinement/rewrite.  This mirrors the earlier
W1/W2 lesson that interface structure should not automatically become causal
protocol.

### 4. Loops are a domain-neutral geometric substrate

Higher loops support phase, thermodynamic affinity and sign Theories.  The same
incidence can carry different algebras; closed-loop invariants arise from the
incidence topology plus Theory, not from domain-specific carriers.

### 5. The graded/source lift is not optional

At both lower and higher ranks, bare Geometry may have the same local shape while
denoting different source-rank objects.  Relative exact lifts appear to be part
of any serious dimensional construction law.

### 6. Causal SCC shadowing remains special

When higher incidence is genuinely causal and cyclic, SCC normalisation still
casts one lower causal event; a further descent becomes structural.  This law
survives domain relabelling and remains the strongest evidence for a systematic
cross-rank causal shadow.

## What this changes

The current evidence argues against a simple picture such as:

```text
W3 = transformations of W2
W2 = transformations of W1
W1 = reduction of W2
W0 = reduction of W1
```

A better working picture is:

```text
rank 3: native deformation/coherence/refinement incidence over exact rank-2 surfaces
            |                         |
            | relative lifts         | causal shadow when applicable
            v                         v
rank 2: native scarce causal processes and exact histories
            |
            | exact occurrence / boundary reduction
            v
rank 1: native configurational/interface/compatibility incidence
            |
            | support
            v
rank 0: locality/support
```

There may be native objects at every rank; reductions, projections, thickenings
and causal shadows are relations between ranks rather than definitions of one
rank in terms of another.

This makes programming callability look like one useful W1 presentation problem,
not the motivation for the dimensional structure.

## Shadow-dive programme

A further `shadows/` programme now fixes lower structural shadows and explores
the space of higher realisations above them: cellular homology, causal
polarisation fibres, associahedral coherence, cubical closed surfaces, Membrane
support independence, latent locality activation and failures of lower
shadow tomography.  Its central negative result is that an ordinary `Face`
cannot serve as a causally neutral higher coherence filling: filling a structural
loop necessarily polarises its boundary.  See `shadows/README.md` before
promoting any of these experiments into the domain-specific folders.
