# Worlds formalisation plan — 0.2

The 0.2 rewrite deliberately makes the executable kernel closer to the intended mathematics before Lean work begins.

The first formal target is finite Worlds only.

## 1. Carrier

Define finite:

```text
World
Point
Strand
Face
```

with World residence, Point incidence, Face input/output incidence, Point equivalence, distinguished actuality root and the certification laws.

## 2. Derived topology

Define:

```text
actuality / detachment
connected detached patch
incoming boundary
returned boundary
generated roots
```

without stored polarity or gate metadata.

## 3. Attachment

For actual locality `K` and detached open patch `P`, define

```text
Att K P
```

as complete admissible boundary embeddings.

Important properties to prove early:

```text
locality
scarcity / injectivity on authority occurrence
Point-binding consistency
equivariance under patch isomorphism/permutation
non-generation by query
```

## 4. Graft

Define fresh grafting from a witness:

```text
μ : Att K P
----------------
graft K P μ = K'
```

The first major theorem should be certification preservation:

```text
Certified K
μ : Att K P
----------------
Certified (graft K P μ)
```

Freshness and locality should ideally be short corollaries of the construction.

## 5. Residuals only after the base theorem

Once attachment/graft are stable, investigate exact residual attachment:

```text
b / a
```

and whether commuting residual squares derive a precubical/cubical configuration structure.

Do not add concurrency primitives to the carrier to make the proof convenient.

## 6. Executable correspondence

The Lua implementation is an oracle, not the formal definition. Its retained fail-first search, serial ordering and dependency fingerprints are intentionally absent from the mathematics.

Differential/property tests should compare the solver to an exhaustive finite attachment relation for small models.
