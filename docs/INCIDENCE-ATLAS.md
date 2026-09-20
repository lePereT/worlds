# Incidence atlas

**Status: non-authoritative research note for Worlds 0.6.2.**

This note records derived structures exposed by experiments over the unchanged
0.6 kernel. None of these names adds a carrier, changes an API or overrides
`LAWS.md`. The purpose is to stop repeatedly mistaking latent structure for a
missing primitive.

## 1. Two incidences already coexist

A Strand has an ordered, multiplicity-preserving tuple of exact Points. A Face
has unordered finite collections of distinct input and output Strand
occurrences. This gives two qualitatively different incidences:

```text
Point <-> Strand     configurational / structural incidence
Strand -> Face -> Strand     scarce causal incidence
```

Point-Strand cycles do not imply causal cycles. A tensor-style factor network can
therefore be represented by face-free open Strands sharing Points, while an
actual contraction schedule is represented by Faces.

## 2. Persistent structure and linear occurrence

Points and Membranes can be mentioned repeatedly without consumption. Exact
Strands are scarce: one exact source occurrence cannot satisfy two target
requirements in one solution.

A useful derived split is therefore:

```text
persistent structural identity    Point, Membrane
linear causal occurrence          Strand
transformation                     Face
```

Scarcity is exclusivity, not conservation: a Face may explicitly split one
occurrence into many or merge many into one.

## 3. Endpoint support patterns

A Strand inhabits one exact Membrane, while each Point in its ordered tuple has
its own exact home Membrane. Together these induce a finite support pattern in
the membrane forest.

Matching does not require an isomorphic embedding of this pattern. Target-local
Membranes are positive structural variables: distinct siblings may identify with
one source locality, while asserted equality and parent relations must remain
consistent. This is closer to parent-preserving unification than rigid subtree
matching.

Across several Strands, shared Points couple these support patterns. The query
engine's endpoint-thread quotient is disposable machinery for a declarative
structure of equality and ancestry constraints.

## 4. Structural rows and exact occurrence fibres

For a live Strand `s`, the derived structural signature

```text
(membrane(s), ordered points(s))
```

groups exact occurrences into a row. The row does not replace its members:
consuming one exact occurrence rather than another changes which authority
survives.

For `n` exact occurrences in one row and `k` structurally identical scarce
demands, the unconstrained allocation count is the falling factorial

```text
n! / (n-k)!
```

until capacity is exceeded. This separates structural feasibility from injective
allocation while preserving exact authority.

## 5. Binding, rigidity and freshness

A Geometry may mention an exact imported Point without owning it or its membrane
ancestry. Such identity is rigid under matching.

A target-owned Point behaves differently. It may be substituted by matching,
and its substitution is dependent on the target's local membrane pattern.
Distinct local Points carry no implicit disequality and may identify.

If an owned local Point is not bound to existing structure, materialising the
Development gives it fresh exact identity. That identity may later be imported
rigidly. The observed lifecycle is:

```text
local owned variable
      | bind                 | materialise
      v                      v
existing exact identity   fresh exact identity
                              |
                              | later reference
                              v
                         rigid parameter
```

This is a derived binding/freshness calculus, not a new Point kind.

## 6. Causal availability of locality

Membranes are not merely static containers. Existing Point/Membrane structure
used downstream must be causally available through input incidence; fresh
locality must descend from available or freshly generated support.

Thus locality itself has causal provenance.

## 7. Tree support already has a restricted join

Within one membrane tree, least common ancestor acts as least common enclosing
support. Worlds uses this when placing a joint Face after SCC normalisation.

The research question is therefore not whether membranes possess any
semilattice-like operation, but why the stronger laminar/tree restriction is the
right law for causal support. Cross-cutting classifications should not be made
membranes merely because they are sets.

## 8. Join equations generate congruence

An equation between open Strands identifies more than those two occurrences.
Ordered Point slots induce Point equalities; locality constraints induce
Membrane equalities; the resulting congruence propagates through other incidence
which mentions the affected carriers.

A useful schematic is:

```text
Strand equation
      |
      v
Point + Membrane congruence
      |
      v
global rematerialisation of affected incidence
```

## 9. Join image is identity transport

The image returned by `join` records construction-relative transport of exact
identity. In ordinary acyclic cases it is kind- and incidence-compatible. Under
quotienting it may identify carriers; under materialisation it maps template
carriers to fresh result carriers; under SCC contraction internal Strand classes
may have no surviving Strand image while several Faces map to one joint Face.

It is therefore better read as exact identity transport with possible
identification, recreation and annihilation than as simple provenance.

## 10. Frame/template polarity

The first part of `join` is a frame. Unaffected frame carriers survive literally;
non-frame structure is materialised as needed. Reversing part order reverses the
preferred exact representatives without reversing causal equation direction.

The same Geometry can therefore act either as existing actuality or reusable
presentation according to its role in composition. A reusable Development does
not require a separate Template carrier.

Frame preservation is maximal rather than absolute: if a congruence changes a
frame carrier's incidence, that carrier may need rematerialisation.

## 11. Boundary as support-closing projection

`boundary(G)` both forgets closed causal interior and retains the owned Point and
Membrane ancestry needed to interpret exact egress. It is therefore not mere
deletion; it projects to live authority and closes that authority under required
support.

## 12. Geometry versus executable Development

Lawful Geometry need not be a rooted executable Development. Matching has a
causal-development premise which direct finite closure does not. This preserves a
useful distinction between a structural object and a construction enactable from
an open interface.

## 13. Current synthesis

The strongest working interpretation is:

```text
persistent Point/Membrane context
        |
        | non-injective dependent unification
        v
exact instantiated context

exact Strand occurrences
        |
        | injective scarce allocation
        v
target requirements

Faces transform those occurrences while preserving, binding, creating or hiding
persistent structure.
```

This helps explain why the replaceable query engine naturally contains both
structural factorisation and Hall-style allocation.

## 14. Consequence for Theory and domain research

The previous research programme often treated quantum phase, tensor structure,
probabilistic dependency, polynomial elimination and related cases as evidence
that Worlds needed another geometric axis.

The revised programme first represents extensional *scope* with existing open
Point-Strand incidence and uses Faces only for causal realisation. Theory then
supplies the algebra carried by that scope and decides propositions which
Geometry cannot decide, such as tensor equality, polynomial consequence,
statistical independence or quantum separability.

This suggests a disciplined division:

```text
Geometry: which exact things participate, where, and with what authority?
Theory:   what is true of those participants, and what survives hiding?
Backends: which lawful causal/physical realisation should be selected?
```

The key falsifier remains important: if a domain requires a new distinction in
causal permission or exact operational identity which cannot be represented by
these incidences, a Geometry extension may be warranted. Rich mathematics alone
is not such evidence.
