# Worlds 0.3 formalisation plan

Formalise finite Worlds with carrier `World`, `Point`, `Strand`, `Face`, derived
open patches, available Frontiers and the complete relation `Att_F(P)`.

The first major theorem remains certification preservation under fresh graft.
The 0.3-specific target is exact residuality:

```text
mu : Att_F(P)
----------------
F / mu
```

must preserve exact consumed supply, fresh symbolic egress and Point identity
without rematching. Pointed Cuts should agree with the independent
set-theoretic completed-Face definition.

Then formalise cubical completion: for a coherent exact family, every subset
induces one residual Frontier and all face maps commute. Derived predecessor,
local-conflict and independence predicates should be theorems over this
structure rather than new carrier relations.

The Lua implementation is an executable oracle, not the formal definition.
Search order, retained-query scheduling and cache/index choices are deliberately
absent from the mathematics.
