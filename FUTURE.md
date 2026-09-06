# Future

This is the working programme. The order matters less than the discipline: derive before adding.

## 1. Derive `develop` completely from geometry

The executable model already does this operationally, but the formal story should expose the derivation cleanly:

```text
stable Point incidence
        ↓
entry-gate candidates
        ↓
detached World-root stage
        ↓
open frontier orientation
        ↓
World-local structural matching
        ↓
prospective use-site check
        ↓
fresh graft
```

The proof obligations should then become consequences:

```text
freshness
actual-subcomplex preservation
scarcity
unique provenance
causal acyclicity
locality
```

One correction to preserve in future formal work: scarcity is about **input use-sites**, not merely distinct consuming Faces. A Face with inputs `[r,r]` uses `r` twice.

## 2. Extend frontier abstraction after 0.1

`v0.1.0` includes the first generic artefact-level frontier variable and complete `specialise` operation. The immediate source-less non-tail-call pressure which produced it is now represented without a continuation object in the kernel:

```text
provider geometry

call gate:
    schema
    args
    continuation-schema
    ...α
```

`α` is not a kernel object. It is a finite abstract Point row used by the separate-compilation artefact layer.

At source-less link time:

```text
A[α] -- specialise(α := F) --> A[F]
```

Every occurrence of `α` expands coherently to the same suspended identity shape. Actual generative Points still bind later during `develop`.

The 0.1 tests cover coherent repeated occurrence, equivalence shape, empty rows, multiple variables, generativity, malformed substitution and the prohibition on sending a `FrontierVar` into the kernel.

Next questions are deliberately narrower:

- partial specialisation and substitution composition;
- canonical serialisation/hashing of abstract artefacts;
- public frontier equivalence under private substitutions;
- capability/effect rows as a second real consumer;
- locality and certification-preservation proofs for `specialise`.

Keep `specialise` outside the kernel unless a hostile example proves that impossible.

## 3. Formal verification

`formal/README.md` lays out the first proof programme. Do not formalise Relay or a production allocator first. Formalise the small mathematical object.

A good first milestone is:

```text
Certified(K)
Develop(K,u,K')
----------------
Certified(K')
```

followed by locality, freshness, custody and non-interference.

## 4. Factorise finite choice

The current finite-choice result uses complete-path expansion. It establishes representability, but not an efficient compiler representation.

We want to factor common prefixes and suffixes:

```text
        common prefix
             |
           choice
          /      \
         A        B
          \      /
          generic join
             |
        common suffix
```

and prove equivalence to the path-expanded resource semantics without exponential duplication.

## 5. Harden Point gluing

The executable cross-carrier experiment uses direct equivalence-class mutation. A production/reference boundary should make compound Point-gluing and development transactional or persistent.

Identity commitment is semantic commitment; failure must not leave half a quotient behind.

## 6. Fixed points

Actual causal cycles are currently rejected.

Ordinary recursion unfolds fresh occurrences and remains acyclic. Mutually recursive initialisation requires explicit bootstrap geometry.

Do not add a `recursive` flag. Either discover a principled fixed-point geometry or keep explicit bootstrap as the answer.

## 7. Borrowing and authority patterns

Exclusive loan/return already looks like ordinary authority flow. Attack:

```text
shared loans
reborrowing
exclusive/shared transitions
higher-order escape
retirement while borrowed
```

Only add lifetime machinery if geometry genuinely fails.

## 8. Effects, handlers and continuation frontiers

Dynamic handler selection already works through Point identity and detached stages.

The new frontier-abstraction work should be tested against:

```text
continuation tails
ambient capability rows
effect-handler frontiers
opaque higher-order returned callables
```

A good result would be one artefact abstraction mechanism rather than separate continuation/effect/module machinery.

## 9. Infinite and reactive behaviour

The current causal law describes finite realised history. Fibers and reactive systems need potentially unbounded unfolding.

The likely direction is infinite production of fresh finite history, not an actual finite causal cycle. This needs precise semantics.

## 10. Nondeterminism and probability

The kernel deliberately rejects two structurally indistinguishable alternatives rather than inventing a chooser.

If genuine nondeterminism or probability is required, find the smallest geometric source of choice rather than placing hidden policy in `develop`.

## 11. Compiler experiments

Once the laws are stable enough, measure the practical consequences:

```text
canonical frontier hashes
semantic ABI comparison
recursive invalidation boundaries
parallel detached-stage certification
World/Point indexes for local matching
distributed provider custody
```

The implementation goal is simple to state:

> compile independently until the geometry proves that coordination is necessary.
