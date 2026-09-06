# Worlds test suite

The test suite exercises the Worlds 0.4.0 kernel directly:

```text
Geometry + membrane selection + exact Attachment + fresh gluing
```

It intentionally contains no compatibility layer for earlier Worlds models and
constructs no transaction, residual, frontier or boundary object.

The directed cases cover:

- geometry, membrane locality and ordered incidence;
- complete attachment and selection entitlement;
- scarcity, identity sharing and non-injective Point substitution;
- fresh gluing, generativity and recursive unfolding;
- exact isomorphism and commuting-development laws;
- extensional value interpretations without merging exact identity;
- Theory admissibility with accepted, rejected and unknown judgements;
- nominal interaction, name passing and fresh-name extrusion;
- proof relevance and proof irrelevance;
- term rewriting and quotient-sensitive process semantics;
- cases where an extensional quotient is not a congruence for exact contexts;
- derived Theory-sensitive attachment over equivalent process representatives.

The suite includes an independent exhaustive attachment oracle for small
geometries. Production attachment results are compared against it so solver
strategy remains separate from semantic meaning.

Higher constructions such as geometric `each`/`together` products are tested in
client experiments rather than being promoted to kernel test fixtures before
their derived laws are settled. Their durable implications belong in
`RESEARCH.md` until they become part of a stable derived library/theory.

`documentation_test.lua` fixes the maintained documentation set. Progress
reports and experiment journals do not belong in the release repository;
durable kernel statements belong in `LAWS.md` and current open work belongs in
`RESEARCH.md`.
