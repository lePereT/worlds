# W3 shadow dive

This folder deliberately heads into the fibres rather than trying to define a
new kernel carrier.  The working question is:

> If exact W2 histories are only lower shadows of a richer space, what structure
> becomes visible when we hold a shadow fixed and vary everything Worlds still
> permits above it?

Nothing here proposes production API.  The experiments reuse ordinary Worlds as
an executable microscope and then record where that microscope itself becomes
too restrictive.

Fourteen pressures currently pass, totalling **3,298 assertions**.

## 1. An honest cellular sublanguage exists inside Worlds

`01_cellular_subgeometry.lua` restricts attention to Strands with exactly two
Point endpoints and Faces attached to cycles.  After forgetting causal polarity,
this sublanguage is an ordinary finite cellular 2-complex over GF(2):

```text
unfilled n-cycle:  b0=1, b1=1, b2=0
filled n-cycle:    b0=1, b1=0, b2=0
```

The chain law `d1 d2 = 0` holds mod 2 for every tested cycle.

This is useful because it makes the phrase "2-complex" precise in one real
subclass of Worlds rather than metaphorical.  General Worlds remains broader:
Strands may have ordered repeated Point rows, and Face polarity carries causal
semantics absent from an ordinary cellular boundary.

## 2. Causal polarity is a large fibre over one structural 2-cell

The same n-gon can be filled by a single Worlds Face under every choice of which
boundary Strands are inputs and which are outputs.  All `2^n` polarisations are
lawful; all except the all-output/no-input case are developable.

If a genuine rewrite is required to have at least one input and one output, the
fibre has `2^n - 2` exact causal histories over the same filled structural disk.

For a pentagon (`02_pentagon_polarisation_fibre.lua`):

```text
structural filled disk              1
causal polarisations               30
dihedral symmetry classes           6
one-edge-flip adjacencies           70
cycle rank of the flip graph        41
```

Thus one apparently simple coherence pentagon already hides a connected
30-state causal fibre with 41 independent graph cycles before any domain Theory,
W2 source lift, or Membrane variation is added.

`06_shadow_fibre_growth.lua` shows the rapid growth:

```text
n   causal polarisations   local-flip edges   fibre cycle rank
3           6                    6                   1
4          14                   24                  11
5          30                   70                  41
6          62                  180                 119
7         126                  434                 309
8         254                 1008                 755
9         510                 2286                1777
```

The adjacency relation here is deliberately only a minimal-edit probe, not a
claim that Hamming distance is canonical W4 structure.  Its purpose is to show
that the fibre is already combinatorially enormous once causal polarisation is
allowed to vary.

## 3. The associahedron appears from actual exact W2 construction histories

`07_associahedron_from_histories.lua` constructs four composable ordinary Faces
and forms the five binary parenthesisations of their composition:

```text
(((12)3)4)
((12)(34))
(1(2(34)))
(1((23)4))
((1(23))4)
```

All five are exact W2 construction histories with the same exposed A->E process
boundary.  Their elementary reassociations form the Stasheff pentagon as a
higher face-free shadow.

The unfilled pentagon has one mod-2 H1 generator.  Filling it kills that loop,
but using an ordinary Worlds Face to do the filling forces one of the thirty
causal polarisations above.

So associativity coherence supplies a concrete non-programming reason to want a
higher **structural filling** which is not automatically a directed causal
rewrite.

## 4. A causally neutral higher 2-cell is missing from the current vocabulary

`14_neutral_fill_impossibility.lua` makes the limitation exact.

Before filling a pentagonal deformation loop, every edge is simultaneously open
on both sides:

```text
5 ingress
5 egress
```

After adding any ordinary Worlds Face, every edge is forced onto exactly one
causal side:

```text
input edge  -> ingress only
output edge -> egress only
```

No Face filling leaves the structural loop boundary neutral/open.

Therefore ordinary Worlds reused one rank up can express:

- face-free higher adjacency;
- directed higher rewrite;

but not a neutral 2-dimensional coherence filling without adding causal
polarity.

This is the strongest current evidence that a genuine W3 cannot simply mean
"interpret today's Point/Strand/Face vocabulary one rank higher" if W3 is to
contain higher structural coherence as well as directed refinement.

## 5. The 2-complex connection is real but only unoriented in the obvious way

`10_oriented_boundary_obstruction.lua` asks whether the mod-2 cellular law lifts
to the ordinary integer-oriented chain complex by taking:

```text
Strand row [vi,vj]      as vi -> vj
Face output Strand      coefficient +1
Face input Strand       coefficient -1
```

For n-gons of sizes 3 through 9, `d1 d2 = 0` over the integers only for the two
uniform polarisations (all input or all output).  **No genuine input/output
rewrite** is an oriented cellular 2-cell under the Strand's intrinsic Point-row
orientation.

Modulo 2, all of them are perfectly good cells.

So Worlds contains a real unoriented cellular shadow, but causal input/output
polarity is not the same thing as topological orientation.  Treating those two
notions as one would erase information.

## 6. Closed higher surfaces expose a topology/developability split

`03_cube_shadow_tomography.lua` builds the six square Faces of a cubical sphere:

```text
V=8, E=12, F=6
b0=1, b1=0, b2=1
```

All twelve edges are internal, so there is no ingress or egress.  The Geometry
is lawful but nondevelopable.

Remove the causally earliest square (`x0`) while leaving the complete Point/
Strand 1-skeleton in place:

```text
b0=1, b1=0, b2=0
4 ingress edges
developable = true
```

Remove the causally latest square (`x1`) instead:

```text
same disk homology
4 egress edges
0 ingress
developable = false
```

Thus two topologically identical punctures have opposite causal behaviour.
Topology does not determine causal developability.

The full sphere and both disks have exactly the same complete Point/Strand
skeleton.  Their difference lives entirely in higher filling data.  Lower
1-skeleton tomography is therefore not faithful.

## 7. Higher topology and higher causality can vary independently

`05_topology_vs_causality.lua` builds two squares glued along one edge, giving a
single cellular disk (`b0=1,b1=0,b2=0`).

One Worlds realisation has:

```text
left coherence Face -> right coherence Face
```

and another has:

```text
right coherence Face -> left coherence Face
```

The Point/Strand skeleton, Face boundary sets, support and homology are the same.
Only causal incidence differs.

So even a complete cellular 2-complex does not determine its Worlds causal
history.

## 8. Membrane behaves as an independent support axis

Three experiments press this directly.

### `04_membrane_support_axis.lua`

The same square cellular filling is lawful with its Face hosted at the root or
at either sibling child of the same Membrane tree.

A higher causal SCC built from two Faces in distinct child supports contracts to
one joint Face hosted at the LCA/root, while both old child supports remain
distinct.

This distinguishes two laws:

```text
ordinary Face host       chosen causal locality
SCC joint-Face host      canonical LCA rehosting
```

LCA is therefore a normalisation law, not a general "cell must live at the
support containing its boundary" law.

### `08_membrane_depth_fibre.lua`

With Point/Strand/Face incidence held fixed, the same cellular Face can be hosted
at arbitrary tested Membrane depth 0 through 12.  All versions are developable.

Support depth is therefore not reconstructible from the cellular incidence.

### `13_cross_local_host.lua`

A Face may be hosted in child A while simultaneously consuming and producing
Strands/Points in sibling B (or vice versa), provided both localities are
causally available.

Membrane placement is therefore not ordinary topological containment of a cell's
boundary.  It behaves much more like an orthogonal causal locality/site axis.

## 9. Support can be latent until causal activation

`11_latent_support_activation.lua` uncovers a stranger distinction.

A closed, nondevelopable cubical sphere can place all six unreachable Faces in
one shared child Membrane even though their causal edge incidence lives at the
root.  Because no Face is causally reachable, locality availability is never
exercised.

Puncture the causal source.  The remaining five Faces become reachable.  The
same shared-child placement is then rejected with:

```text
existing locality used without causal input incidence
```

Move the causal edge incidence into the shared child so that the locality itself
is carried by the causal boundary, and the punctured disk becomes developable
again.

So there is a real distinction between:

```text
latent support in nondevelopable structural higher geometry

and

causally available support in an executable higher history.
```

This is strong evidence that Membrane semantics is coupled to causal
reachability rather than merely decorating an underlying cell complex.

## 10. Hidden dimensions multiply

`12_product_fibres.lua` varies only two axes above one structural pentagonal
disk:

- 30 causal input/output polarisations;
- Membrane host depth 0 through 7.

All 240 combinations are lawful and developable while retaining exactly five
Points, five Strands and one Face.

This is only a sampled product fibre.  It does not yet include:

- exact W2 history denoted by each higher Point;
- alternative higher adjacency structures;
- domain Theory;
- Membrane branching rather than depth;
- multiple coherence Faces;
- exact construction path.

The fibre of realisations over a low-dimensional shadow is therefore plausibly
much larger than the first W1/W2 reductions suggested.

## 11. The fibre itself casts a further shadow

`09_polarisation_over_polarisation.lua` treats the thirty causal fillings of one
pentagon as thirty exact higher histories and builds a face-free next-rank atlas
using one-edge causal flips.

The common lower object is a contractible filled disk:

```text
b0=1, b1=0, b2=0
```

but the fibre above it has:

```text
30 higher Points
70 higher Strands
cycle rank 41
```

Thus topological triviality at one rank can sit beneath substantial topology in
the space of its realisations one rank higher.

This is the clearest executable example so far of the intuition that we may be
seeing only shadows of a much richer realisation space.

## Current interpretation

The experiments argue against collapsing the following notions:

```text
cellular incidence
causal polarisation
causal developability
Membrane support/locality
exact construction history
higher deformation adjacency
```

They can vary independently, although Worlds construction laws couple them in
specific places (notably SCC/LCA normalisation and causal locality availability).

A useful provisional picture is therefore not a single dimensional tower but a
stratified family of fibres:

```text
                 higher realisation/deformation space
                       /      |       \
                      /       |        \
             causal history  support   Theory
                    \          |       /
                     \         |      /
                    structural/cellular shadow
                              |
                              v
                         lower shadow
```

### What ordinary Worlds captures well one rank up

- exact higher alternatives;
- face-free adjacency between them;
- directed causal rewrite;
- SCC normalisation and causal shadowing;
- Membrane locality and LCA rehosting.

### What it currently cannot express neutrally

A structural 2-dimensional coherence filling which kills a higher loop while
leaving its boundary merely structural.  The only available 2-cell is `Face`,
and `Face` necessarily chooses causal input/output polarity.

That limitation may be pointing towards genuine missing higher structure rather
than a need for more encoding cleverness.

## Next questions suggested by the shadows

1. Is there a rank-polymorphic notion of **structural cell** distinct from causal
   transformation, or should structural coherence live in another derived rank?
2. Can complete lower atlases ever be tomographically faithful, or do higher
   filling classes remain invisible even to every lower view?
3. What is the correct invariant of the causal-polarisation fibre: ordinary
   homology, groupoid structure, representation theory, something directed?
4. Does the membrane/support fibre combine with causal polarisation as a genuine
   fibration, or do more examples reveal monodromy/obstruction between them?
5. Are associahedra, permutohedra and cubes the beginning of a systematic family
   of coherence polytopes naturally generated by exact Worlds construction?
6. Can SCC/LCA normalisation be reformulated as a universal operation across
   these fibres without making arbitrary Face hosts canonical?

For now the most useful result is negative and generative at once:

> A W3-like realisation space is already much richer than its lower cellular
> shadow, while today's Worlds vocabulary forces structural 2-dimensional
> coherence to become causal if we try to fill it directly.

## 11. Fixed-shadow realisation-fibre census

A further programme in `fibre_census/` now fixes the complete cubical
Point/Strand skeleton and enumerates fillings, causal validity, Membrane support
and exact construction history rather than varying one axis at a time.

The headline findings are:

- 64 cellular fillings -> 32 lawful causal materialisations -> 10 developable;
- with a fixed `root/{A,B}` support tree, 4096 raw face states -> 2304 lawful ->
  120 developable;
- the lawful minimal-edit realisation complex has GF(2) Betti numbers
  `(1,18,135,220,175,74,13)`;
- the developable locus has `(1,15,8)`;
- adding sibling Membrane choices changes executable-fibre homology from
  contractible (no child) to `(1,5)`, `(1,15,8)`, then `(1,30,66)` for one,
  two and three child localities;
- the q=4 H1/H2 generators have explicit support/causal representatives; and
- a seven-Face causal chain already admits 8448 exact construction histories
  from parenthesisation and frame/template choices while retaining one coarse
  causal shadow.

See `fibre_census/README.md` for the full census and caveats.  The coordinate
cubical adjacency is an experimental probe of the fibre, not a proposed kernel
operation or canonical next-rank incidence.

## Deeper fixed-shadow census: causal spines and support moduli

The `fibre_census/` continuation now finds an exact causal-spine locality law and
substantial further topology.  Membrane support is relative to the Membrane
carrying causal authority: the root-to-support spine is reusable, while each
off-spine subtree is an exclusive branch resource.  The resulting support
realisation fibres have RAAG/Salvetti-like homology generated by commuting local
support loops; moving authority down the same Membrane tree produces a nested
persistent-topology filtration and can reveal previously latent branching.

Most strikingly, with sufficiently many Faces the realisation/moduli space has
nonzero homology in arbitrarily high degree even though every individual Worlds
object still uses only Point/Strand/Face.  This separates kernel carrier rank
from the topological dimension of the space of its exact realisations.

## Between-Worlds continuation

`between_worlds/` follows the strongest deep-fibre conjecture directly: perhaps
part of the higher-dimensional object is not another carrier inside one World,
but the structured collection of exact Worlds and lawful relations between them.

The continuation finds both a strong positive and an important falsifier:

- actual exact Worlds over one fixed causal shadow can be materialised as Points
  of a face-free higher atlas;
- the liberal support-jump atlas has a fundamental group whose presentation
  Tietze-reduces exactly to the predicted RAAG commutation presentation in all
  tested cases;
- **the same exact Worlds become contractible under parent/child-only Membrane
  moves**, so topology is not determined by the vertex set alone;
- native `join` construction images nevertheless supply a privileged
  source-relative structure: different equation orders and one-shot quotienting
  yield exact-distinct endpoint Worlds connected by coherent incidence-preserving
  correspondences;
- that coherence survives causal SCC contraction, many-to-one Face images and
  annihilated cyclic authority;
- forgetting provenance exposes factorial matching symmetry and non-free
  coordinate-permutation stabilisers; and
- the structural-vs-causal distinction repeats at the meta-level: reversible
  structural deformation can be loop-rich while causal rehosting toward the
  active support is terminating and confluent.

The resulting working picture is therefore category/groupoid/complex-like rather
than `W3 = set of W2 Worlds`.  See `between_worlds/README.md` for the full
experimental account.
