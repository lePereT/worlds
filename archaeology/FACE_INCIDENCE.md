# Face incidence

**Status: archaeology; experiment record whose adopted laws now live in `../docs/LAWS.md`.**

This branch tests the hypothesis that Strand Point incidence is ordered but a
Face's input and output Strand incidence are finite unordered sets.

## Why

SCC normalisation previously concatenated member Face incidence in SCC/member
presentation order.  Because Face incidence was declared ordered, tensor
presentation order could therefore become semantic after a simultaneous joint
occurrence.  There is no intrinsic ordering of an SCC or symmetric tensor
factor family from which such an order can be derived honestly.

## Result

The complete Worlds gate passes with Face incidence represented as sets.  The
explicit hostile A/B mutual-support case also passes under both part orders and
both cut orders while preserving distinct rigid external input/output roles.

No current kernel, Theory, geometric-products client or Relay-source client
uses Face incidence position semantically.  Cut relies on ordered Strand Point
incidence, which is unchanged.

## Consequences

* A Face is an oriented hyperedge: input and output polarity matters, but order
  within either side does not.
* Multiplicity remains exact because different Strand occurrences remain
  different set members.  Duplicate use of the same Strand is still invalid.
* If argument/port position matters, it must be represented explicitly in
  Strand Point incidence (for example Arg0/Arg1 Points) or in Theory.
* SCC contraction is set union of external member incidence after internal
  support is removed.  No arbitrary sorting is a semantic rule.
* Relay semantic transport must normalise Face incidence before hashing so a
  non-semantic presentation order cannot affect content identity.
* Explain/source correspondence may still present ports in source order as
  non-semantic metadata.

## Representation

The research fork stores Face incidence as Lua hash sets deliberately, to make
any accidental positional dependence fail loudly.  This is not a requirement
of the semantic model.  For LuaJIT the likely production representation is a
compact array of distinct Strand references treated as an unordered
enumeration; permanent membership indexes should only be added if measurements
justify them.

## Release implication

If adopted before 0.5.0 is released, this is a carrier-law clarification and
should be reflected in LAWS/MODEL/API and Relay's semantic-patch transport.
There is no evidence from the current corpus that another 0.5 law must change.
