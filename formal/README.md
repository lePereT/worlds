# Formal verification

There is deliberately no Lean, Coq or Isabelle code in `v0.1.0`.

The kernel is small enough that the first job is to choose definitions which make the intended theorems simple, rather than to commit early to an implementation encoding.

## Mathematical object

The first formal carrier should need little more than:

```text
finite World forest with actuality root Ω
Point identities and Point equivalence
World-resident Strands
World-resident Faces
Strand -> Point incidence
Face -> input/output Strand incidence
```

Actuality is reachability to `Ω`, not a stored bit.

Fresh IDs, union-find, arrays, caches and indexes are implementation choices and should stay out of the first specification.

## Define development relationally first

Prefer:

```text
Develop K trigger K'
```

to an executable `develop : Kernel -> Strand -> Kernel` at first.

The relation should derive:

```text
entry gate
stage
open demands
local match
prospective use-sites
fresh graft
```

from geometry.

Only afterwards should an executable matcher be proved sound and complete with respect to the relation.

## First theorem targets

A useful first sequence is:

1. Worlds form a well-founded forest and actuality is reachability;
2. actual geometry is an honest subcomplex;
3. detached Faces cannot hold realised Strand authority;
4. successful development preserves certification;
5. generated Worlds/Points/Strands/Faces are fresh;
6. development is local to the trigger World plus its selected detached-stage index;
7. Point gluing cannot teleport Strand authority;
8. disjoint developments commute up to fresh renaming;
9. retirement cannot discard unspent resident authority;
10. finite-choice normalisation preserves the earlier path resource criterion.

## A correction to keep explicit

Resource use must be defined by **input positions**, not simply by the set of Faces which mention a Strand.

```text
Face inputs = [r, r]
```

contains two uses of `r` even though there is one consuming Face.

That distinction matters for the scarcity theorem and should be built into the first formal definition.

## Frontier abstraction

`specialise` should be formalised outside the kernel as a transformation on parametric compiled artefacts:

```text
A[α] -> A[F]
```

where `α` ranges over abstract Point-frontier shape. The useful theorem is certification preservation under valid substitution, not a new kernel primitive.

## What would count as success

If the central preservation, locality and non-interference proofs are short once the geometry is defined, that is evidence that the kernel has found a good abstraction.

If those proofs need hidden environments, path tables or feature-specific cases, that is evidence against the current design and should feed back into the kernel before a large formal development accumulates.
