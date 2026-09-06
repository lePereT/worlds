# Laws

The kernel is intended to be read geometrically. These are the current laws, not an attempt to define a full programming language.

## 1. Carrier

There are four semantic objects:

```text
World
Point
Strand
Face
```

Every Point, Strand and Face is resident in one World. Worlds form a forest with one distinguished actuality root `Ω`.

A Strand is incident on Points. A Face consumes and produces Strands.

## 2. Actuality is topology

A World is actual iff following `parent` reaches `Ω`.

```text
actual                           detached

   Ω                                D       G
   |                                 \     /
   W                                  stage
```

There is no `latent` or `realised` bit on a World.

Actual Strands may mention only actual Points. Actual Faces may consume or produce only actual Strands. The actual part is therefore an honest subcomplex.

## 3. Identity and authority are different

Point gluing means semantic identity.

Strands are occurrences of authority. Gluing Points does **not** move or duplicate a Strand.

```text
Provider                  Client

   ● F  =================  ● F
    |                       |
 provider authority     client authority
```

The identity may be shared. The authority is not.

Detached geometry may share realised Point identity, but a detached Face may never hold a realised Strand directly. A future needing authority must demand it through its frontier or receive it through explicit transport.

## 4. A stage is World-local geometry

A development stage is a connected component of detached World roots.

Once a root participates, all of its resident geometry belongs to the stage. Distinct detached roots join the same stage only through ordinary incidence.

This matters for terminal geometry such as:

```text
r? -> EPSILON
```

which remains part of its World even though the incidence ends there.

## 5. Demand is derived

An incoming suspended Strand is a demand when it is consumed by the stage and not produced by the stage.

Roots containing incoming demands are demand roots. Other roots in the stage are generated roots.

There is no polarity field.

## 6. Development is local grafting

For an unspent actual trigger `u` in World `W`, `develop(u)`:

1. finds exactly one compatible detached gate sharing stable Point identity with `u`;
2. discovers its stage;
3. matches every demand only against unspent actual authority resident in `W`;
4. resolves the generated Face input positions through that match and rejects any old Strand whose prospective use count would exceed one;
5. creates fresh copies of generated World roots beneath `W`;
6. substitutes matched frontier cells and preserves realised Point anchors;
7. reconstructs ordinary incidence;
8. realises exactly one Face consuming the trigger.

Failure is transactional.

The detached archetype is not mutated.

## 7. Matching does not guess

Structural matching preserves dimension, sort, arity and Point incidence.

A demanded cell has one binding in one development. Non-injective matching is allowed, so late aliasing remains literal geometry:

```text
demand a ----\
              >---- r
demand b ----/
```

If that would cause two input positions to consume one occurrence, `develop` rejects the match transactionally **before grafting**.

If several equally valid supplies exist, development is ambiguous and is rejected.

## 8. Authority is World-local

A development may use:

```text
trigger
+ other unspent Strands in trigger.world
+ their Point incidence
```

Faces are history, not supply. Authority in an ancestor, descendant or sibling World is unavailable unless ordinary Face geometry transports it into the triggering World.

## 9. Provenance, copy and discard

Each realised Strand occurrence has at most one producer and at most one consumer use-site.

Structural copy and discard are explicit:

```text
        r                       r
        |                       |
      DELTA                  EPSILON
      /   
    r1     r2
```

A normal Face may produce multiple same-typed values when their identities are genuinely distinct. It may not silently copy one authority occurrence.

## 10. Causal history is acyclic

The realised causal relation:

```text
Strand -> Face -> Strand
```

is acyclic.

Recursion is fine because it unfolds fresh occurrences:

```text
(f0,s0) -> (f1,s1) -> (f2,s2) -> ...
```

A closed source-free causal loop is not execution history. If the kernel eventually needs fixed points, they require explicit theory rather than weakening this law silently.

## 11. Choice is competing possibility

Finite alternatives may be represented by competing detached stages. Only the selected stage becomes actual.

A path using a resource zero times consumes it through `EPSILON`; repeated use goes through `DELTA`; one use is direct. This reproduces the earlier 2-complex path scarcity criterion in the current finite normalisation experiment.

Branches can rejoin through an open branch identity:

```text
true  -> fresh q1 --\
                     >-- generic join
false -> fresh q2 --/
```

No phi object is required for the cases tested so far.

## 12. Separate compilation exposes geometry, not metadata

A stage frontier is derived from:

```text
open incoming Strands
+
produced Strands with no internal consumer
```

There is no `public` bit on cells.

Private names may disappear from a canonical frontier while identity correlations remain. Provider detached geometry may stay in provider custody; shared Point identity can be glued across carriers without importing provider Strand authority.

A separately compiled artefact may also contain abstract **Point-row frontier variables** outside the kernel. `specialise` replaces each variable coherently with a finite sort/equivalence shape and yields an ordinary closed Separate unit. Frontier variables cannot inject Strand authority, Faces or actual Worlds and cannot cross the `Separate.import_unit` boundary.

## 13. Retirement is a judgement, not state

There is no `World.closed` bit.

At an attempted exit, a World subtree is retirable iff no unspent realised Strand remains resident anywhere in it.

```text
live World                    retirable World

  held state                    state
                                  |
                                EPSILON
```

Before exit is attempted, live retained state and leaked state with identical geometry are intentionally indistinguishable.

## 14. Static and actual geometry obey the same resource discipline

Detached stages are certified before they are trusted. An invalid unchosen branch is still invalid.

The same incidence ideas therefore govern both:

```text
possible geometry   before develop
actual geometry     after develop
```

## 15. Current boundary

The kernel does not yet claim a general answer for:

```text
general fixed points
shared borrowing / reborrowing
infinite behaviour
genuine nondeterminism / probability
full domain-specific conservation
factorised large choice DAGs
frontier abstraction / specialise
```

Those belong in `FUTURE.md`, not in hidden flags inside the carrier.
