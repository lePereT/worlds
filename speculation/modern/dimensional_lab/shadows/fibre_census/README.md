# Fixed-shadow realisation-fibre census

This subprogramme follows the shadow-dive conclusion literally:

> hold a lower shadow fixed and systematically enumerate what Worlds still
> permits above it.

The primary shadow is the complete Point/Strand 1-skeleton of a cube.  The
experiments vary, separately and together:

- which of its six square 2-cells are present;
- the fixed causal polarity inherited from the cube-face ordering;
- Face support on a fixed Membrane tree;
- developability;
- and, in a separate causal-chain pressure, exact join construction history.

The local-edit/cubical geometry introduced here is explicitly an experimental
probe of the finite realisation fibre.  It is **not** proposed as canonical W3
or W4 incidence.

## 1. Sixty-four fillings over one complete 1-skeleton

`15_fixed_shadow_filling_census.lua` keeps all eight Points and twelve Strands
fixed and considers every subset of the six cubical square Faces.

Combinatorially there are 64 cellular fillings.  Under the fixed causal
polarisation:

```text
64 combinatorial fillings
32 lawful Worlds materialisations
10 developable/executable histories
```

By number of present Faces:

```text
Faces   candidates   lawful   developable
0           1           1          1
1           6           3          2
2          15           5          2
3          20           7          2
4          15           9          2
5           6           6          1
6           1           1          0
```

All seven expected homology stages occur, from the bare cube graph
`(b0,b1,b2)=(1,5,0)` to the closed sphere `(1,0,1)`.

A notable negative result is that, among the 32 lawful current-Worlds fillings,
the exact ingress/egress status of all twelve fixed edges uniquely determines
which Faces are present.  The lower **causal** boundary therefore leaks the
higher filling completely in this restricted family.

This is consistent with `14_neutral_fill_impossibility.lua`: because every
ordinary Face must polarise each incident Strand as input or output, today's
vocabulary has no neutral structural filler which could vary while leaving the
exact lower causal boundary unchanged.

So there are two tomography statements, not one:

```text
Point/Strand skeleton alone       highly non-faithful
exact causal boundary status      faithful here because filling is causalised
```

A future neutral higher cell should be expected to break the second statement.

## 2. Membrane activation carves the support fibre

`16_membrane_activation_fibre.lua` fixes not only the cube skeleton but also a
support tree:

```text
       root
       /  \
      A    B
```

Each of six square Faces has four states:

```text
0 absent
1 hosted at root
2 hosted at A
3 hosted at B
```

Thus there are exactly `4^6 = 4096` raw realisation states.  Exhaustive Worlds
construction gives:

```text
4096 raw states
2304 lawful states
 120 developable states
```

The closed sphere is strikingly permissive.  All `3^6 = 729` assignments of its
six Faces to `root/A/B` are lawful, and none develops.  Its support is latent.

Puncture the causal source Face while keeping the same lower skeleton.  Five
Faces remain, so there are `3^5 = 243` support assignments.  Only **31** are
lawful, and all 31 develop.

Those 31 obey a simple operational rule in this experiment:

```text
at least 3 of the 5 reachable Faces stay at root;
at most one reachable Face may use A;
at most one reachable Face may use B.
```

Reusing a reachable child locality would require causal incidence carrying that
locality.  By contrast the closed nondevelopable sphere never exercises the
availability law.

The one-host-edit graph of the 31 active support states is connected with:

```text
V = 31
E = 55
cycle rank = 25
```

The fully latent sphere support fibre is the Hamming graph `K3^6`:

```text
V = 729
E = 4374
cycle rank = 3646
```

Causal activation therefore does not add a simple coordinate.  It cuts a very
specific executable locus out of a much larger support fibre.

## 3. The combined lawful realisation space has high-dimensional cubical structure

`17_global_realisation_space.lua` uses one local state change at one Face as a
minimal-edit adjacency over the 4096-state support/filling space.

The lawful and developable 1-skeleta are both connected:

```text
                    V       E      graph cycle rank
lawful            2304   16940          14637
developable        120     386            267
```

Every lawful state lies within five such edits of the developable locus:

```text
distance 0   120
distance 1   360
distance 2   858
distance 3   756
distance 4   204
distance 5     6
```

Independent edits give a canonical *probe* cubical structure: a k-cube is kept
whenever all `2^k` combinations of k independent coordinate changes are lawful
(or developable).

Its f-vectors are:

```text
k                    0      1      2      3      4      5     6
lawful            2304  16940  49636  74677  61616  26697  4770
developable        120    386    358    106      8      0     0
```

So the lawful fibre contains complete coordinate cubes through dimension six.
The executable locus has cubical dimension four.

Euler characteristics are:

```text
lawful        12
developable   -6
```

## 4. Homology: the hidden fibre contains genuine higher holes

The heavier reproducible analysis is in:

- `emit_support_vertices.lua`
- `cubical_homology.py`
- `run_homology.sh`

It computes GF(2) cellular homology of the experimental coordinate cubical
complex.

For the two-child (`q=4`) case:

```text
lawful fibre Betti numbers
(1, 18, 135, 220, 175, 74, 13)

executible/developable locus
(1, 15, 8, 0, 0, 0, 0)
```

Thus filling all commuting squares/cubes does **not** erase the apparent graph
complexity.  The lawful realisation fibre retains holes through dimension six,
including thirteen independent top-dimensional classes in this finite probe.
The executable locus retains fifteen 1-cycles and eight genuine 2-cycles.

These numbers depend on the deliberately chosen minimal-edit cubical probe; the
claim is not that Worlds has canonically acquired these Betti numbers.  The
important result is that a simple, domain-neutral local notion of changing one
hidden realisation coordinate exposes substantial nontrivial topology above a
fixed lower shadow.

## 5. Membrane branching creates topology in the executable realisation space

The same homology analysis varies only the number of sibling Membrane choices.
Let a Face have q possible states:

```text
0 = absent
1 = root
2..q-1 = one of q-2 sibling child Membranes
```

For the **developable** locus:

```text
q   child siblings   vertices   Betti numbers
2        0              10      (1)
3        1              35      (1, 5)
4        2             120      (1, 15, 8)
5        3             385      (1, 30, 66)
```

With no child locality, the executable fibre is contractible under this probe.
One child creates five independent loops.  Two children create fifteen loops and
eight two-dimensional holes.  Three children give thirty loops and sixty-six
2-cycles.

The first Betti number follows the exact law in these cases:

```text
b1 = 5 * b1(K_q)
   = 5 * (q-1)(q-2)/2
```

The factor five is the five non-source cube Faces.  Each inherits the cycle
space of its q-state support-choice graph.  Causal asymmetry has therefore
become visible as topology in the realisation fibre.

This is a much stronger Membrane/dimensionality connection than simply saying
"more Membranes give more configurations".

## 6. The surviving q=4 holes have a concrete causal/support interpretation

`interpret_developable_homology.py` extracts explicit representatives.

All fifteen H1 classes may be chosen as the three independent triangles among:

```text
absent / root / A / B
```

for each of Faces 2 through 6 in the fixed causal ordering.  The causal source
Face 1 contributes none.

So:

```text
5 non-source Faces * 3 cycles of K4 = 15
```

The eight H2 classes have equally concrete representatives.  Each is a
nine-square product torus.  There are two such classes for each coordinate pair:

```text
(Face 2, terminal Face 6)
(Face 3, terminal Face 6)
(Face 4, terminal Face 6)
(Face 5, terminal Face 6)
```

giving `4 * 2 = 8` classes.

The representatives are products of three-edge support/absence triangles.  The
2-dimensional holes therefore arise from coupled alternative support cycles,
not opaque matrix artefacts.

## 7. Exact construction history is another enormous fibre over one causal shadow

`18_exact_construction_history_fibre.lua` fixes an ordinary linear causal chain
of N Faces.  It varies only:

- binary parenthesisation of composition; and
- at every internal join, which already-constructed side is passed as the first
  frame versus the freshly materialised template.

For ordered N leaves this gives:

```text
N   parenthesisations   frame choices   exact construction histories
3          2                 4                    8
4          5                 8                   40
5         14                16                  224
6         42                32                 1344
7        132                64                 8448
```

Every one of the 8448 N=7 constructions has the same coarse causal-chain
signature:

```text
7 Faces
1 ingress
1 egress
```

but every tested construction path produces a distinct tuple of exact Face
identities under the Worlds 0.6.2 frame/template materialisation law.

Thus even after topology, causal polarity and Membrane support are fixed, exact
construction path supplies another rapidly growing hidden fibre.

## Current interpretation

The fixed-shadow experiment now exhibits at least four separable layers:

```text
fixed lower Point/Strand shadow
        |
        +-- higher cellular filling
        |
        +-- causal polarity / developability
        |
        +-- Membrane support and availability
        |
        +-- exact construction identity
```

The layers are not a Cartesian product.  Causal activation cuts the support
fibre; current causal filling leaks into the exact lower boundary; and exact
materialisation history proliferates even when every coarse causal observable is
held fixed.

Most importantly, the *space of realisations itself* acquires topology under a
minimal local-edit probe, and Membrane branching changes that topology in a
systematic, causally asymmetric way.

This makes the "shadow" language more concrete: what is lost below is not just
one hidden label.  A fixed shadow can sit beneath a structured space of exact
realisations with loops, surfaces and higher-dimensional holes of its own.

## 8. The executable vertex set has an exact causal-mask × support-injection law

`21_cube_executable_formula.lua` removes another layer of mystery.  For the
fixed cubical causal ordering, the developable vertices are characterised
exactly (exhaustively through `q=6`) by two independent-looking conditions:

1. the set of present Faces is one of ten fixed causal masks; and
2. root hosting may be reused, while every off-spine child host is used at most
   once among the present Faces.

The ten masks contain:

```text
0 Faces      1 mask
1..4 Faces   2 masks at each size
5 Faces      1 mask
```

If `m=q-2` is the number of sibling child Membranes and

```text
F_k(m) = sum_j C(k,j) (m)_j
```

counts root-or-injective-child assignments to `k` present Faces, then the whole
executable census has the closed form:

```text
D(m) = 1 + 2(F1+F2+F3+F4) + F5
     = m^5 - 3m^4 + 13m^3 - 3m^2 + 17m + 10.
```

This gives the observed sequence:

```text
child siblings m    0    1    2    3     4     5     6
vertices            10   35   120  385   1118  2895  6700
```

The q=7 and q=8 values were separately materialised exhaustively during this
round as a heavier pressure and agree with the formula.

So causal combinatorics and support branching really can be separated at the
vertex-set level here: the ten causal masks stay fixed while Membrane branching
expands the support-realisation fibre above each mask.

## 9. Causal support defines a spine, and off-spine subtrees are branch resources

`19_causal_spine_support_law.lua` tests a richer nine-Membrane tree with nested
side branches.  For a linear chain whose authority Strands all live at Membrane
`M`, the observed Worlds locality law is exactly:

```text
Membranes on root..M causal spine
    reusable arbitrarily

each connected subtree hanging off that spine
    one branch resource
    at most one Face may be hosted anywhere in that subtree
```

The law agrees with Worlds on every three-Face host assignment for three
successive choices of causal support (`2201` assertions).

This explains several earlier oddities.  Two different deep Membranes in the
same off-spine subtree conflict because using either exercises the same branch
locality.  Two sites in different branches can coexist.  Moving the causal
Strands down into a branch rebases the spine and can turn previously conflicting
sub-branches into independent alternatives.

The relevant support geometry is therefore **relative to the Membrane carrying
causal authority**, not a static property of the Membrane tree alone.

## 10. Fixed support fibres have RAAG/graph-braid-like homology

`20_support_configuration_homology.py` isolates the support part of the law.
For `k` reachable Faces over a causal support with `m` sibling off-spine
branches, a vertex is a partial injection:

```text
Face -> {causal support, child_1, ..., child_m}
```

where the causal support may repeat and a child may not.

For all `k<=5`, `m<=6`, direct cubical homology gives:

```text
beta_r = C(k,r)
         C(m,2) C(m-2,2) ... C(m-2r+2,2).
```

The generators have a concrete interpretation:

- an H1 generator chooses one Face and two child branches, giving the triangle
  `support -> child_a -> child_b -> support`;
- an r-dimensional torus chooses r different Face coordinates and r pairwise
  disjoint pairs of child branches.

Consequently the highest possible nonzero degree is

```text
min(k, floor(m/2)).
```

The same Betti vectors are exactly the clique numbers of the natural
**local-loop commutation graph**: vertices are those support triangles; two are
adjacent when the two locality variations can be carried out independently.
This is precisely the homology pattern of a Salvetti complex/right-angled Artin
group.  No fundamental-group or homotopy-equivalence proof is claimed yet, but
the match holds for every tested star and causal-spine profile.

This is a useful conceptual shift: the hidden topology is behaving like a space
of **commuting locality moves**.

The same clique law survives the asymmetric nine-Membrane tree used by the
exhaustive causal-spine test.  For three Faces, moving causal support down
`R -> A -> B` keeps `84` H1 generators but reveals progressively more compatible
higher products:

```text
support R   beta=(1,84, 90,   0)
support A   beta=(1,84,630, 324)
support B   beta=(1,84,975,1642)
```

In all three cases the Betti vector is exactly the clique vector of the natural
locality-loop commutation graph.  Causal depth is therefore changing which of
the same local alternatives can commute, not merely creating more alternatives.

## 11. Membrane branching can be topologically latent until causality resolves it

The same four named support sites can produce very different higher topology
depending on the current causal support.

For four Faces:

```text
support view     vertices      Betti numbers
star @ root          73        (1,12,0,0,0)
path @ root          13        (1,12,0,0,0)
fork @ root          13        (1,12,0,0,0)
fork @ A            128        (1,12,12,0,0)
```

From the root, the entire subtree under `A` is one exclusive off-spine branch,
so an internal path and fork are indistinguishable to this support fibre.  Move
causal authority to `A`, and its children become separately available branches;
twelve H2 classes appear.

Thus internal Membrane branching can exist structurally while remaining
**topologically invisible at the current causal resolution**.

## 12. Descending the causal spine raises moduli-space dimension

On the fixed path

```text
root -> M2 -> M3 -> M4
```

keep the same four-Face causal chain and the same four possible Face hosts, but
move the authority Strands progressively down the path.  Actual Worlds
materialisations have:

```text
causal support   vertices      Betti numbers
root                13         (1,12,0,0,0)
M2                  80         (1,12,0,0,0)
M3                 189         (1,12,30,28,9)
M4                 256         (1,12,54,108,81)
```

At `M4` every host lies on the causal spine, so the realisation complex is the
full product `K4^4`; its Poincare polynomial is

```text
(1 + 3t)^4.
```

More generally, with `s` reusable support sites and `k` Faces, the deepest-spine
family gives

```text
(1 + C(s-1,2)t)^k.
```

Hence the realisation/moduli space has nonzero H_k for arbitrary k (when
`s>=3`) even though every individual Worlds object is still built from the
ordinary Point/Strand/Face kernel.

This decisively separates **carrier/incidence rank** from the topological
dimension of the space of exact realisations.

## 13. Causal depth gives a persistent-topology filtration

`24_causal_depth_persistence.py` uses the fact that the four path fibres are
nested:

```text
X_root <= X_M2 <= X_M3 <= X_M4.
```

It computes the induced maps on GF(2) homology.  Every existing class survives
the next inclusion; no class dies in this family.

```text
depth 0 births   (H0,H1,H2,H3,H4) = (1,12,0,0,0)
depth 1 births                         (0,0,0,0,0)
depth 2 births                         (0,0,30,28,9)
depth 3 births                         (0,0,24,80,72)
```

So descending causal support does not create new local H1 alternatives.  The
same twelve basic locality loops persist.  What changes is which loops may
commute; deeper authority adds higher tori around those existing moves.

This makes the "causal resolution" language precise for this family: causal
descent **reveals independence relations** in previously latent Membrane
structure.

## 14. The global executable holes are also concrete product tori

`22_executable_product_tori.py` returns to the full filling+support fibre.  For
`q=4,5,6`, every observed nonzero homology class through H3 has a representative
which is a product of local one-coordinate state triangles.

```text
q=4   beta=(1,15,8)
q=5   beta=(1,30,66)
q=6   beta=(1,50,276,72)
```

The coordinate pattern itself becomes causally asymmetric:

- H1: every non-source Face contributes equally;
- H2: middle/middle and middle/terminal coordinate pairs carry different class
  multiplicities as branching grows;
- H3 at q=6: every class uses the terminal Face together with two middle Faces
  (`6` coordinate triples, `12` classes each).

Thus the higher holes are not opaque matrix artefacts even after filling and
support are coupled.  They remain built from products of local alternative
cycles, but causal position controls which products survive globally.

## 15. No small-characteristic torsion signal yet

`23_coefficient_field_pressure.py` orients the experimental cubes and recomputes
homology over odd prime fields.  The Betti numbers agree with the GF(2) results
for:

```text
q=4   GF(2), GF(3), GF(5)
q=5   GF(2), GF(3), GF(5)
q=6   GF(2), GF(3)
```

This does not prove integral torsion-freeness, but it rules out a tempting
explanation in which the observed higher holes are merely mod-2 orientation or
low-prime torsion artefacts.

## Revised interpretation after pulling the Membrane thread

The new evidence suggests a much sharper separation:

```text
ordinary Worlds carrier rank
    Point / Strand / Face

Membrane support geometry
    viewed relative to current causal support
    -> causal spine + off-spine branch resources

space of exact realisations
    local support loops
    commutation relations among those loops
    higher product tori / arbitrarily high homology
```

The last line can have unbounded topological dimension while the first remains a
2-complex-like kernel.  "W3" therefore cannot simply mean "the next integer
above Face" if the intended object is the whole space hidden above a shadow.
There is a distinct **moduli dimension** generated by alternatives and their
commutation.

A particularly productive conjecture is now available for falsification:

> For fixed causal support, the Membrane realisation fibre is homotopy-equivalent
> (after collapsing inessential local trees) to a Salvetti-like complex whose
> generators are local support loops and whose higher tori encode compatible
> commuting locality moves.

The experiments establish the corresponding homology/clique law, not yet the
fundamental-group statement.
