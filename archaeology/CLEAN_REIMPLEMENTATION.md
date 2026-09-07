# Clean reimplementation notes

**Status: archaeology; implementation-history note.**

This tree was written after freezing `worlds-0.5.0-candidate-research-7`.
It intentionally does not preserve that branch's internal representation.

## What became smaller

Research-7 source: approximately 985 Lua lines.

Clean source: approximately 659 Lua lines.

The largest structural reduction is operational state.  Research-7 represented a
Boundary as a membrane tree with local boundary sets and pruning.  The clean
model observes that membrane identity is not an authority-discovery mechanism,
so operational execution never needs to search that tree.  Boundary is therefore
just the exact live egress Strand set plus its cardinality.

`Boundary` and `Step` also cease to be top-level peers of the semantic algebra.
They are one `Operational` namespace implementing the state/history commuting
square.

## What was not preserved

The clean implementation deliberately has no:

- semantic sorts;
- Selection/View API;
- ambient Point enumeration;
- membrane authority or membrane-based offer discovery;
- operational history/delta chain;
- future-cut/reclamation subsystem;
- boundary membrane tree;
- global generation epoch;
- demand×offer candidate matrix;
- separate matcher for Step or composition.

## Test migration

Semantic tests were regrouped by law.  Representation-specific tests were
rewritten rather than copied.  In particular, old membrane-tree node-sharing
checks became exact frame-preservation assertions.

The original research-7 archive remains the independent archaeological oracle;
its SHA-256 is recorded under `archaeology/`.
