# Worlds 0.2 laws

Worlds is intended to be read geometrically. These are the current kernel laws and the 0.2 attachment law; they are not a programming-language ontology.

## 1. Carrier

There are four semantic carrier objects:

```text
World
Point
Strand
Face
```

Every Point, Strand and Face is resident in one World. Worlds form a forest with one distinguished actuality root `Ω`.

A Strand is incident on Points. A Face consumes and produces Strands.

No `Attachment`, function, continuation, borrow, transaction or concurrency object is added to the carrier in 0.2.

## 2. Actuality is topology

A World is actual iff following `parent` reaches `Ω`.

```text
actual                         detached

   Ω                              D       G
   |                               \     /
   W                            open patch
```

There is no latent/realised state bit.

Actual Strands may mention only actual Points. Actual Faces may consume or produce only actual Strands. The actual part is therefore an honest subcomplex.

## 3. Identity and authority are different

Point gluing means semantic identity.

Strands are occurrences of authority. Gluing Points does not move, mint or duplicate a Strand.

```text
● A  =================  ● B
 |                       |
sa                      sb
```

The identity may become shared while authority remains where its Strand is resident.

Detached geometry may share actual Point identity, but a detached Face never possesses an actual Strand directly. Actual authority enters a possible patch only through a boundary attachment.

## 4. Open patches are derived

An open patch is a connected component of detached World roots together with the boundary induced by its incidence.

Once a detached root participates, all geometry resident in that root participates. Distinct roots become one patch only through ordinary Point/Strand/Face incidence.

No cell stores `input`, `output`, `public`, `gate`, or polarity metadata.

Incoming boundary, generated interior and returned egress are derived from topology.

## 5. Demand is derived

An incoming suspended Strand is a demand when it is consumed across the detached-root geometry and is not produced there.

Roots containing incoming demand are demand roots. The remaining roots of an attachable patch are generated roots.

The complete incoming boundary includes the incidence needed to match those demands consistently.

## 6. Attachment is the semantic possibility relation

For an actual locality `K` and detached patch `P`,

```text
Att_K(P)
```

denotes the complete admissible boundary embeddings of `P` into the currently available boundary of `K`.

A witness

```text
μ ∈ Att_K(P)
```

matches the whole incoming boundary simultaneously.

It is not an ordered sequence of local matching decisions.

Matching preserves:

```text
dimension
sort
incidence arity
Point identity constraints
exact-World locality
scarcity of Strand authority
```

Only unspent actual authority resident exactly in `K` may satisfy a Strand demand. Faces are history, not supply.

## 7. Search order has no semantic force

The implementation may discover a complete attachment incrementally, fail-first, by serial number, through indexes, or by another solver.

Those choices do not define `Att_K(P)`.

In particular:

```text
local ambiguity       ≠ semantic ambiguity
search exhaustion     ≠ impossibility
sibling enumeration   ≠ causal order
```

A globally coupled boundary may have one complete witness even when an early local demand has several candidates. Conversely an early local ambiguity may occur in a completely empty attachment space.

## 8. Sibling order is not causal order

Isomorphic/permuted descriptions of an open patch induce corresponding attachment spaces. Reordering sibling occurrences may transport occurrence/result identities, but may not change:

```text
inhabitation of Att_K(P)
emptiness of Att_K(P)
the causal/resource world represented by a complete attachment
```

All semantically meaningful order must occur in causal incidence or in explicit theory data, never in list position or search traversal.

## 9. Querying is non-generative

Asking whether `Att_K(P)` is inhabited does not alter actuality and does not allocate fresh semantic identity.

The public retained query may report:

```text
hit       a constructive attachment witness exists
retry     the current complete attachment space has been exhausted/refuted
unknown   this finite search has not yet decided
```

`unknown` is an algorithmic/epistemic state, not a state of the Worlds geometry.

A Retry certificate may record the actual facts on which its refutation depended; certificate invalidation is implementation evidence, not an additional semantic object.

## 10. Graft is actualisation

Given a revalidated witness

```text
μ ∈ Att_K(P)
```

`graft(μ)`:

1. freshens the generated roots and generated cells of `P`;
2. attaches the fresh Worlds beneath actual locality `K`;
3. substitutes the matched incoming boundary;
4. preserves actual Point anchors;
5. reconstructs ordinary incidence;
6. returns any topologically derived egress to `K`.

The detached archetype is unchanged.

Failed/stale grafts are transactional and leave no partial actual geometry.

Fresh identity belongs to graft, not to search.

## 11. Multiplicity is not an error

The following are distinct semantic facts:

```text
|Att_K(P)| = 0       presently impossible
|Att_K(P)| = 1       uniquely attachable
|Att_K(P)| > 1       several complete attachment witnesses
```

Worlds does not invent a selection policy for the final case. A search implementation may expose one constructive witness, but witness discovery order is not semantic preference; committing one witness among several is an explicit choice made above `Att_K(P)`.

Choice, preference, fairness and scheduling belong above the carrier/attachment relation.

## 12. Provenance, copy and discard

Each realised Strand occurrence has at most one producer and at most one consuming use-site.

Structural duplication and disappearance are explicit causal witnesses:

```text
        r                       r
        |                       |
      COPY                   DISCARD
      /  
    r1    r2
```

A normal Face may produce several genuinely distinct authorities. It may not silently duplicate one occurrence.

Higher theories determine where explicit copy/discard are admissible.

## 13. Actual causal history is acyclic

The realised causal relation

```text
Strand -> Face -> Strand
```

is acyclic.

Recursion/reactivity unfolds fresh occurrences. A source-free causal cycle is not execution history.

Transactional constraint solving or open-process composition must not smuggle a cyclic provisional search structure into actual causal geometry.

## 14. Separate compilation exposes geometry

A portable frontier is derived from open incoming authority and outward-facing produced authority. There is no public/private bit on kernel cells.

Private names may disappear while Point-equivalence correlations remain.

Artefact-level frontier variables remain outside the Worlds carrier and specialise to ordinary closed Point geometry before import.

## 15. Retirement remains a judgement

There is no `World.closed` bit.

At an attempted exit, a World subtree is retirable iff no relevant unspent realised authority remains resident in it.

Before exit is attempted, retained live state and leaked state with identical geometry are intentionally indistinguishable.

## 16. Derived structure is not promoted prematurely

Experiments around 0.2 indicate that residual attachment may derive:

```text
causal enabling
conflict
independence
cubical higher concurrency
```

and that open-process composition may explain much of Fibers `and_then`, `each` and `together`.

These are research consequences of attachment, not new 0.2 carrier laws. They belong in `RESEARCH.md` until established mathematically.
