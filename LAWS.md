# Worlds 0.3 laws

## 1. Carrier

The semantic carrier consists only of `World`, `Point`, `Strand` and `Face`.
No attachment, residual, conflict, concurrency, resource or compiler-interface
metadata is stored in the carrier.

## 2. Actuality is topology

A World is actual exactly when its ancestry reaches the distinguished actuality
root. Actuality is not a mutable flag.

## 3. Identity and authority differ

Point identity may alias. Strand authority is occurrence-sensitive and scarce.
A Point relation never permits rematching or duplication of a Strand occurrence.

## 4. Open patches are derived

Detached connected geometry induces its open patch, incoming demands, egress
and generated roots. Those classifications are not stored.

## 5. One possibility relation

For any available Frontier `F` and detached patch `P`:

```text
Att_F(P)
```

is the set of complete admissible attachments of `P` to `F`.

An actual locality derives one Frontier. Exact residual development derives
another. Both are interpreted by the same relation.

## 6. Complete means simultaneous

Every incoming boundary demand is satisfied in one Witness with consistent
Point bindings, exact locality and injective use of scarce Strand authority.
Local greedy choices have no semantic status.

## 7. Search is not semantics

Retained queries may report `Hit`, `Retry` or `Unknown`. `Unknown` means search
has not established either possibility or present emptiness. Search order and
budget do not change `Att_F(P)`.

## 8. Witnesses are exact

A Witness records one exact complete attachment. Revalidation checks that exact
chosen geometry; it never reruns search to discover an equivalent Witness.

## 9. Residual Frontiers are exact

For exact Witness `mu`, `mu:after()` removes precisely the scarce supplies
consumed by `mu`, retains unrelated available authority, and adds precisely its
symbolic egress and fresh identities. No rematching and no carrier mutation
occur.

## 10. Pointed Cuts are exact

`mu:cut()` derives the internal live Strand cut of that one attached patch.
`cut:after(face)` consumes exact live inputs and exposes exact outputs. A Cut
contains no linearisation history; only the unordered past and current cut are
observable.

## 11. Graft is actualisation

Only a current exact Witness over a live actual Frontier can graft. Graft is
fresh and preserves certification when its premises hold.

## 12. Scarcity derives local conflict

Two currently possible exact occurrences which require the same scarce supply
cannot coherently co-complete at that Frontier. No Conflict relation is stored.

## 13. Residual completion derives independence

A family is independent at a Frontier exactly when its exact occurrences admit
a coherent cubical completion: every subset has one residual vertex and every
face map reaches the corresponding enlarged subset vertex.

## 14. Symbolic egress derives causality

If a later exact occurrence consumes symbolic egress or fresh identity produced
by an earlier occurrence, that predecessor relationship is derived from the
geometry. Sequential exploration alone creates no causal predecessor.

## 15. Conflict is local

Failure of current co-completion does not imply hereditary conflict. An event
may transform authority and thereby enable a fresh later occurrence of a patch
which competed with its earlier occurrence.

## 16. Higher cells are not carrier objects

Squares, cubes and higher cells are properties of residual completion under
`Att_F(P)`. Worlds stores no cube or concurrency ontology.

## 17. Certification and separate compilation preserve geometry

Certified Readers expose immutable nameless geometry. `Att` may operate over
that geometry directly. `Separate` transports detached geometry without adding
language-specific interface ontology.
