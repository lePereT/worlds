# Between Worlds: is the higher dimension a space of exact Worlds?

This subprogramme investigates the conjecture suggested by the deep-fibre work:

> perhaps an individual World is one exact realised point, while genuinely
> higher-dimensional structure lives in the lawful relations, deformations and
> construction paths *between* exact Worlds.

The experiments support that conjecture, but with an important correction:
**the set of Worlds alone does not determine a higher space**.  One must also
say what counts as an elementary relation/move/construction between them.
Different such calculi on the same exact vertices can have different homotopy.

The strongest current picture is therefore category/groupoid/complex-like rather
than a new `3-cell` carrier: exact Worlds are objects; construction images,
structural deformations and causal meta-rewrites are different kinds of arrows;
commuting/confluent/path-coherence phenomena live one level higher; and
forgetting exact provenance introduces symmetry/isotropy.

Nothing here changes the Worlds kernel or proposes public API.

## 1. Actual exact Worlds can be the vertices of a higher atlas

`25_between_worlds_moduli.lua` uses the asymmetric nine-Membrane tree from the
causal-spine work and a fixed three-Face causal chain.  Only the Face hosts vary.
Every lawful materialisation is an actual independently constructed Worlds
Geometry with the same coarse causal shadow.

For causal support at successive spine sites:

```text
support       exact Worlds      one-host jump edges      commuting squares
R                  97                  468                    378
A                 356                 2652                   5241
B                 453                 3960                   9891
```

For the A case the experiment materialises a face-free higher atlas with:

```text
356 Points      each Point lifts to one exact World
2652 Strands    one-host structural rehosting relations
0 Faces         the atlas itself adds no lower causality
```

The 5241 independent-move squares are genuinely *between-Worlds* data.  No
single lifted World contains them.  Filling those squares neutrally would again
run into the earlier limitation that ordinary Worlds Faces causalise their
boundary.

This is the first direct executable form of the statement:

```text
one exact World = one point of a larger realisation object
```

rather than merely a metaphor based on counting parameter vectors.

## 2. The jump atlas has an exact RAAG fundamental-group presentation

`26_fundamental_group_raag.py` strengthens the previous homology coincidence.
For each tested jump atlas it constructs the standard fundamental-group
presentation of the cubical 2-skeleton:

1. choose a spanning tree of the move graph;
2. one generator for each non-tree edge;
3. one relator for each commuting square.

It then performs only elementary Tietze eliminations forced by one-letter
relations (`g=1`) and two-letter relations (`g=h^{+-1}`).  No group heuristic or
homology information is used.

In every tested case the surviving presentation consists of:

```text
one generator per local support loop
only commutator relators
```

and its commutation graph is graph-isomorphic to the independently predicted
causal-spine commutation graph.

Representative cases:

```text
case                 pi1 generators   commutators   3-cliques
star k=2,m=4              12                6            0
star k=3,m=4              18               18            0
path at root              12                0            0
path depth 2              12               30           28
asymmetric R              84               90            0
asymmetric A              84              630          324
asymmetric B              84              975         1642
```

Thus the earlier Salvetti/RAAG signal is not merely a Betti-number match in
these finite cases: the actual pi_1 presentation Tietze-reduces to the predicted
right-angled Artin presentation.

This is still an experimental theorem about the chosen jump atlas, not a claim
that Worlds canonically carries a RAAG.

## 3. The same exact Worlds can have trivial topology under a different move law

`27_move_calculus_falsifier.py` is the crucial negative control.

It holds the *vertex set fixed* and compares two elementary-move calculi:

```text
jump
    rehost one Face directly from any support site to any other lawful site

tree-local
    rehost one Face across exactly one Membrane parent/child edge
```

For the same asymmetric support fibres:

```text
support      jump Betti                 tree-local Betti
R            (1,84,90,0)                (1,0,0,0)
A            (1,84,630,324)             (1,0,0,0)
B            (1,84,975,1642)            (1,0,0,0)
```

The standard pi_1 presentation of each tree-local complex Tietze-reduces all the
way to the trivial group.

So the beautiful RAAG topology is **not intrinsic to the set of exact Worlds**.
It belongs to the pair:

```text
(exact Worlds, chosen elementary relation between them)
```

This sharply constrains any W3 interpretation.  A higher object needs an
incidence/move calculus; a collection of lower worlds is insufficient.

The result also clarifies the meaning of the two probes.  `jump` is naturally a
*structural alternative/deformation* relation: child A and child B are simply
two neighbouring choices in the alternative space.  `tree-local` instead treats
rehosting as an *operation through locality*, so A-to-B factors through their
Membrane path.  Those are different semantic questions and should not be forced
to have the same topology.

## 4. Native Worlds construction already supplies path-dependent inter-World arrows

The arbitrary rehosting atlases above need an externally chosen move relation.
`28_native_construction_groupoid.lua` therefore asks what the kernel itself
supplies.

Start from one exact World containing three independent prospective quotient
equations.  Apply them in each of the six possible orders, plus once in a single
one-shot join.

The result is:

```text
7 exact-distinct endpoint Worlds
1 common structural quotient meaning
```

The exact endpoint carriers differ because materialisation history matters.
However, the composed construction image from the common source induces a
carrier-by-carrier correspondence between every pair of endpoints.  The
correspondence is:

- well-defined on quotient classes;
- bijective in this acyclic case;
- kind-preserving;
- Membrane-parent preserving;
- support preserving;
- ordered Point-incidence preserving; and
- producer/consumer preserving.

Most importantly, for every triple of endpoint constructions:

```text
phi_BC o phi_AB = phi_AC
```

exactly on every carrier.

So the parallel construction outcomes form a **thin source-relative groupoid**:
exact codomains remain distinct, while their common marked source provides flat
coherence between them.

This is a much more intrinsic higher structure than the arbitrary rehosting
atlas.  It is made from the kernel's existing `join` images.

## 5. The construction groupoid survives causal SCC normalisation

`29_scc_construction_groupoid.lua` repeats the construction-order experiment
with two equations which together create a causal SCC, plus one independent
acyclic seam.

Depending on equation order, the SCC is formed at different stages.  In every
final outcome:

- the two source Faces map many-to-one to one joint Face;
- cyclic Strand authority is annihilated;
- the independent seam is closed; and
- the endpoint World has the same final causal structure.

All six staged orders and the one-shot join again admit source-relative endpoint
correspondences, and those correspondences compose exactly across every triple.

Thus the groupoid-like coherence is not merely the commutativity of benign
independent equations.  It survives genuine causal normalisation, many-to-one
images and carrier disappearance.

## 6. Provenance marking removes symmetry which bare matching cannot

`30_provenance_and_symmetry.lua` builds `n` structurally identical parallel
channels and independently materialises two exact copies.

With no rigid role marking, ordinary Worlds boundary matching finds exactly:

```text
n=1    1
n=2    2
n=3    6
n=4   24
n=5  120
```

that is, `n!` equally valid port permutations.

Add a distinct rigid exact role Point to each channel and the count becomes one
for every tested `n`.

The common source construction image likewise selects one exact marked
correspondence between the fresh copies even when bare matching still sees the
full permutation fibre.

So the source-relative groupoid is genuinely **marked/indexed by provenance**.
Forget that marking and symmetry reappears.

This repeats the rank/lift lesson at the level of whole Worlds: exact provenance
is not decorative bookkeeping if a canonical higher correspondence is wanted.

## 7. Forgetting exact Face identity produces non-free isotropy strata

`31_unlabelled_support_isotropy.py` applies the coordinate-permutation group S3
to the three-Face support fibre, interpreting this as forgetting which exact
Face occupied which coordinate.

The quotient action is not free:

```text
support   marked Worlds   unlabelled orbits   vertex stabilisers
R              97              21             {1:72, 2:24, 6:1}
A             356              69             {1:306,2:48, 6:2}
B             453              90             {1:378,2:72, 6:3}
```

Full S3 fixed points are precisely repeated placements on reusable causal-spine
supports.  Descending causal support from R to A to B creates one, then two,
then three such fully symmetric points.

So if exact identity is quotiented away, the moduli object develops
support-dependent symmetry strata.  This is more naturally **groupoid/orbifold/
stack-like** behaviour than an ordinary free quotient space.

The terminology is deliberately heuristic: no stack formalism is proposed yet.
The experiment establishes the non-free action and its dependence on causal
support.

## 8. Structural-vs-causal semantics repeats between Worlds

`32_structural_vs_causal_meta_moves.py` gives the two move calculi a directional
interpretation.

The jump atlas is treated as structural alternative/deformation incidence.  It
is reversible and loop-rich.

The tree-local relation is oriented *towards the causal support*.  On exactly the
same Worlds vertices this gives a meta-rewrite system with:

```text
support    Worlds   directed edges   confluence diamonds   max height
R            97          168                72                 6
A           356          876               711                 8
B           453         1152               972                 9
```

Every step strictly lowers total Membrane distance to the causal support.  Every
World reaches the unique normal form:

```text
(all Faces hosted at the causal support)
```

Every pair of independent one-step reductions closes a confluence diamond.
Hence this tested meta-dynamics is terminating and locally confluent, while the
structural alternative atlas on the same objects carries the nontrivial RAAG
fundamental group.

This is perhaps the most suggestive result of the programme:

```text
inside one World
    structural incidence != causal transformation

between exact Worlds
    structural deformation != causal/meta-rewrite
```

The distinction appears to reproduce itself one rank up.

## Current interpretation

The original conjecture was:

```text
perhaps W3 is the space of neighbouring exact W2 Worlds.
```

The experiments refine it to:

```text
not:
    W3 = set/topological space of W2 Worlds

closer to:
    higher object = exact Worlds
                  + chosen relations/constructions between them
                  + coherence among those relations
                  + provenance/marking
```

There are already several non-equivalent kinds of inter-World arrow:

```text
structural deformation
    reversible alternative relation; may carry loops/RAAG topology

causal/meta-rewrite
    directed normalising operation; may be terminating/confluent

native construction arrow
    join image from one exact construction stage to the next

source-relative coherence
    correspondence between exact-distinct outcomes of parallel construction paths
```

Forgetting source marking introduces permutation symmetry and fixed-point strata.

A cautious mathematical analogy is therefore not simply a moduli space but an
**indexed higher groupoid/category/complex**, possibly stack-like after quotienting
exact markings.  The evidence is now strong enough to make those models worth
formal comparison, but not yet to select one vocabulary as the Worlds ontology.

## Main consequence for the dimensional question

Carrier rank and higher dimension have decisively separated.

An individual exact World can remain an ordinary Point/Strand/Face object while:

- being one vertex among hundreds of realisations of the same shadow;
- participating in a nontrivial fundamental group of structural alternatives;
- lying in a terminating causal/meta-rewrite system under a different move law;
- being one exact codomain of several path-dependent native constructions; and
- acquiring isotropy when exact provenance is forgotten.

So at least part of the sought "W3" richness genuinely lives **between Worlds**.
What remains open is whether there is also an intrinsic higher carrier/cell
language required to express neutral coherence fillings and other structure that
cannot be recovered from these inter-World constructions alone.
