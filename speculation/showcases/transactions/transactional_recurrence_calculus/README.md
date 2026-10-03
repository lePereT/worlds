# Transactional Recurrence Calculus

This laboratory extends the package-first finite transactional Development calculus without adding a
`fix` instruction, computation VM, recursive callback, call opcode or live transaction object.

Its thesis is:

> A recursive Relay element is a finite content-addressed graph of open Development contexts.
> Every context is Geometry + Theory. Graph edges tie marked holes to semantic definition roots.
> The denotation is the least positive fixed point of those finite semantic equations.

## Contexts and holes

A Development context contains one finite relative Development template. Its open boundary is
partitioned into:

- the public outer authority/value interface;
- hole-entry outputs which supply a recursively referenced definition;
- hole-return inputs which receive that definition's outputs.

Every boundary position must belong to exactly one of those roles. This is important for authority:
one scarce output cannot silently feed two recursive children.

Filling a hole performs ordinary exact Strand cuts plus positive Theory equality/projection. Non-tail
recursion is therefore represented by a finite wrapper Geometry with structure both before and after
the hole; no stack or continuation object is present in Package meaning.

Multiple holes are positive siblings. Their finite descendants combine with the true Cartesian
product preference order inherited from the finite calculus.

## Recursive Package

A Package stores only canonical finite data:

- semantic definitions keyed by content-derived roots;
- each definition's finite ordered family of Development contexts;
- root references from holes;
- the outer interface shape of each definition.

Source-local definition names are excluded from semantic bytes. SCC roots are derived from anonymous
canonical SCC meaning. Independently compiled Packages refer to one another by semantic root and can
be linked by content-addressed union.

The research SCC canonicaliser enumerates permutations for SCCs up to seven entries. This keeps the
law obvious while avoiding premature production engineering.

## Finite observation of recurrence

`unfold.package(package, root, depth)` returns an **ordinary finite transactional Development
Package**. It starts from empty meaning and computes the requested Kleene approximant. Recurrence
metadata is completely absent from that result.

This operation exists to pressure the denotation and compilation laws. Depth must not be confused
with execution fuel or semantic commit eligibility.

## What recursion discovered about the finite lab

The first recurrence comparison found a genuine finite-calculus canonicality bug. A three-stage
causal chain produced exact-isomorphic Geometry but different symbolic numbering depending on
whether it was compiled incrementally or as a differently parenthesised region.

The finite lab now has a structural Geometry alpha-normal form, and a new pressure verifies causal
chains through eight stages under left- and right-associated compilation. Recurrence then verifies
that each finite unfolding has the same bytes as direct finite compilation of that whole region.

## Key pressures

The laboratory checks:

- local recursive alpha-renaming and definition order do not change semantic roots;
- Package transport is canonical;
- productive recursion grows monotonically from empty meaning;
- pure ungrounded cycles have no finite witness;
- mutual recursion is one content-addressed SCC;
- separately compiled recursive Packages link by semantic root;
- separate and joint compilation agree;
- repeated instantiation freshens exact Worlds identity;
- non-tail recursion remains ordinary Geometry around a hole;
- Theory values can flow through recurrence without causality metadata;
- knowledge can ground a recursive descendant;
- preference waits for complete descendants;
- multiple recursive holes use Cartesian rather than lexicographic preference;
- hole listing order is non-semantic;
- scarce authority cannot be duplicated across holes;
- finite unfolding erases recurrence entirely;
- recursive Package size does not grow with inspected unfolding depth;
- recursive authority becomes an ordinary causal chain;
- independent recursive siblings remain concurrent;
- every completed recursive descendant is one Development;
- recursive-preferred infinite ascent has no stable finite commit frontier;
- grounded preference can stabilise immediately;
- structurally indistinguishable SCC entries hash-cons to one semantic root;
- finite unfolded meaning is invariant under compilation scale.

## Run

From the Worlds root:

    speculation/showcases/transactions/transactional_recurrence_calculus/run_lab.sh

The recurrence laboratory is research code. Production Worlds is unchanged by it.
