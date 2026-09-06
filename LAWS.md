# Worlds 0.4.0 laws

This document states the current Worlds kernel contract. It deliberately does
not record research history or promote useful derived constructions into kernel
ontology.

## 1. Carrier geometry

A Geometry is an immutable finite directed 2-complex inside a forest of
membranes.

The only carrier kinds are:

```text
membrane
Point
Strand
Face
```

There is no kernel carrier for state, transaction, continuation, function,
process, product, conflict, scheduler, resource or concurrency.

## 2. Membranes

Membrane containment is a forest and therefore acyclic.

Every Point, Strand and Face is incident to exactly one membrane. Gluing
preserves valid membrane incidence and ancestry.

A membrane is geometric locality. Selection of a membrane for an attachment
question is contextual and is not stored as semantic state.

## 3. Points

A Point is an atomic exact semantic identity or witness in one Geometry.
Distinct Point cells are distinct exact geometry.

A Point has one membrane incidence. Point identity does not itself confer or
locate scarce authority; Strands carry authority occurrences.

When a Geometry is used as a pattern, Points in pattern membranes mapped to
existing source membranes are variables under attachment substitution:

- one repeated pattern Point must map consistently to one source Point;
- two distinct pattern Points are independent variables and may map to the same
  source Point;
- distinct pattern Points therefore do not assert disequality;
- Points in fresh or unmapped membrane geometry remain fresh and distinct after
  gluing.

Point substitution is functional but not injective.

Worlds Point identity is intensional exact identity. A Theory may define a
coarser extensional equality without changing exact Point identity.

## 4. Strands

A Strand is one authority occurrence, located in one membrane and incident to
an ordered tuple of Points.

A Strand has at most one producer Face and at most one consumer Face.

A Strand with no producer is an open input when its Geometry is used as a
pattern. A Strand with no consumer is terminal authority.

Attachment of open input Strands is injective: one exposed terminal Strand
cannot satisfy two distinct input-Strand demands in one attachment.

Scarcity therefore resides in occurrence identity, not in Point-variable
disequality.

## 5. Faces

A Face is one causal occurrence, located in one membrane, consuming and
producing ordered tuples of Strands.

Producer-to-consumer Face incidence through Strands is acyclic.

Copy- and discard-shaped events are ordinary Faces. Worlds requires such
structure to be explicit; a higher Theory decides whether a particular domain
permits it.

## 6. Selection

For Geometry `G`, a finite set `S` of its membranes may be selected as open
context.

Selection is an argument to an attachment or observation question; it is not a
carrier, lifecycle flag or stored property of `G`.

The exposed terminal authority is exactly terminal Strands whose own membranes
lie in `S`.

Visible Points are Points located in `S` together with Points carried by exposed
terminal Strands. Membrane ancestry alone does not expose another membrane.

## 7. Exact attachment

`Att_S(G,P)` is the family of complete exact attachment maps from the open
boundary variables of pattern Geometry `P` to identity and terminal authority
exposed by selection `S` in source Geometry `G`.

An attachment preserves:

- cell sorts;
- ordered Strand-to-Point incidence after Point substitution;
- Point membrane incidence;
- membrane ancestry;
- injective use of scarce terminal Strands.

The membrane map and Point substitution need not be injective. Aliasing is
ordinary substitution; scarce use is controlled separately by Strand matching.

Any existing membrane which would receive fresh causal or authority geometry
must be explicitly selected. A structurally inferred ancestor may participate
in a map without thereby becoming open for modification.

Attachment is complete evidence for one exact structural composition. Search
strategy, enumeration order and search budget are not part of its meaning.

## 8. Freshness

Pattern cells not identified by an exact attachment are fresh in the glued
result.

Fresh membrane topology is copied exactly from the pattern.

A Point in an already mapped pattern membrane is a boundary variable. It is not
silently generated as fresh identity merely because it had no prior source
name.

## 9. Gluing

For `μ ∈ Att_S(G,P)`, gluing produces a new immutable Geometry:

```text
G' = G ⊕μ P
```

Mapped cells are identified according to `μ`. Several pattern Point variables
may therefore be identified with one source Point. Every unmapped pattern cell
is fresh-copied.

No matching is performed again during gluing. The attachment itself is the exact
evidence controlling the gluing.

The source Geometry is unchanged.

## 10. Exact equality

`Worlds.same(G,H)` is exact geometric isomorphism modulo fresh-name renaming
while preserving shared pre-existing occurrence anchors.

A Theory may define coarser equality over Points or complete geometries without
changing exact Worlds equality.

A quotient or canonical representative is therefore a derived Theory notion,
not a Worlds identity rule.

## 11. Theory admissibility and observation

Exact attachment is structural and theory-blind.

A domain Theory may accept, reject or leave unknown an exact structural
attachment according to interpreted facts. `unknown` is not equivalent to
acceptance or rejection.

A Theory may also define extensional observations and equalities. Such equality
never merges exact Point or Strand identity and never duplicates or consumes
scarce authority by itself.

A Theory quotient is valid only for observations and contexts under which the
stated equality is a congruence. Extensional equality does not automatically
license replacement in arbitrary exact Worlds contexts.

## 12. Theory-sensitive composition

For many domains, semantic composition is exact `Att` followed by Theory
admissibility.

Some domains identify complete geometries by equations such as structural
congruence. Equivalent representatives may then expose different exact
attachment opportunities, so post-filtering one representative's exact
attachments is insufficient.

A higher Theory may therefore derive a quotient-sensitive relation, informally:

```text
Att^T_S([G]_T, [P]_T)
```

using Theory-equivalent representatives, normal forms, equivalence classes or
another sound construction justified by that Theory.

This does not alter the Worlds kernel. Exact `Att` remains the composition
relation of the free/intensional geometry.

## 13. Computation

Computation may be represented as repeated exact attachment and fresh gluing.
There is no mutable transaction or residual-state object in the kernel.

Because Geometry is immutable, provisional semantic development can be
abandoned by discarding the derived Geometry. This does not imply rollback of
irreversible external effects; systems using Worlds must treat physical effect
commitment separately.

## 14. Derived causality, conflict and concurrency

Causality is geometric when a later exact composition requires authority or
identity produced by an earlier occurrence.

Conflict through scarce authority is geometric when otherwise possible
attachments cannot co-complete because they require the same Strand occurrence.

Independent developments may be recognised by commuting gluing diagrams under
exact Worlds equality or, where separately justified, a stated Theory quotient.

No scheduler or source exploration order becomes semantic merely because an
implementation examined developments in that order.

Products, internal cuts, simultaneous joint occurrences and higher-dimensional
concurrency are derived constructions over these laws. They are not additional
kernel carriers or privileged attachment modes in Worlds 0.4.0.
