# Relay open-Geometry/cut experiments

These executable toys ask whether Relay Front can eliminate `hole`/`offer` and
`scalar`/`context` compiler categories in favour of ordinary open Worlds Geometry
plus transient finite boundary selections (“cuts”).

`cuts_disjoint.lua` exercises the direct finite-closure judgement: `Query.close`
ranges over the original disjoint Geometry parts, and every `yes(E)` is consumed
by strict `join(parts, E)` without constructing a staging product.

`cuts_internal.lua` exercises the distinct same-Geometry case. It first establishes
a product Geometry deliberately, then asks `Query.close({product}, ...)` to close
selected cuts inside that already-existing Geometry. This is not asserted to be
equivalent to direct multi-part closure; locality establishment can make the two
judgements differ.

The experiments deliberately create no `Cut` carrier. A cut is a temporary Lua
selection of existing ingress/egress Strand occurrences. The semantic operations
remain Question and strict `join`.
