# Design notes: concurrency discovery

## No concurrency ontology

The arena adds no semantic `Task`, `ChannelState`, `Blocked`, `Runnable`, scheduler, transaction
journal or continuation machine. Facilities construct ordinary open Packages and use the existing
Relay computation algebra.

## The current open-boundary decomposition

The lab now separates four concerns which the earlier `match signature` prototype conflated:

```text
Geometry       exact authority, incidence, locality and causality
Presentation   which public authority occurrences are exposed to this sibling closure question
Theory         positive meaning supported on exact occurrences
Correspondence quotient evidence transporting meaning through Construction
```

An open presentation is semantically relevant to contextual composition but non-authoritative: it
cannot manufacture or identify exact carriers. Strand-supported Theory describes an occurrence but
likewise cannot authorise a cut. Pressure 34 enforces that distinction.

Generic `together`:

1. forms the positive Cartesian sibling tuple;
2. reads only the selected open authority positions;
3. asks Worlds `Close` for exact cut families, with any explicit source-coverage obligations;
4. joins the selected exact Geometry;
5. transports supported Theory through Construction correspondence classes;
6. unifies same-named positive fields on identified classes and rejects contradiction;
7. existentially hides knowledge whose correspondence class has no public surviving support;
8. returns every lawful ordinary Development alternative.

The record-shaped support doctrine is laboratory code. Production Relay should express the same
law through its restrictive occurrence-relative Theory interface rather than standardise record
fields.

## Why correspondence, not image

A rendezvous SCC may annihilate the exact Strand on which interface meaning was supported. A
lawful `Construction:image(source_strand)` can therefore be `nil`. Nevertheless source strands
which were identified before annihilation must contribute their positive knowledge to the same
closure.

`Construction:correspondence()` retains precisely this source quotient class. This is why the
Theory and concurrency lines now fit together without a special matching transport mechanism.

## Rejected: protocol structure as extra Points

A more geometric prototype represented protocol positions with additional Points. It worked for
matching, but descriptive protocol Points survived as internal exact Geometry and substantially
increased canonical symmetry. It also blurred the rule that Points represent exact programme
identity rather than arbitrary descriptive labels.

The arena therefore keeps exact Geometry sparse. Add a Point when exact identity/incidence really
matters; keep protocol description in Theory otherwise.

## Rejected: knowledge implies openness

Another tempting simplification is to treat every authority occurrence carrying positive Theory as
open to `together`. That is too strong. Resources may have rich positive knowledge without being
made available to sibling closure. Pressure 34 distinguishes the two.

The open-boundary selection therefore remains a small Presentation rather than a Theory fact. This
is a candidate for the same representation eventually used by Context holes, Focus reconstruction,
routine resumption and Foreign seams.

## Rendezvous and multi-party synchronisation

Channel send/receive and the unrelated signal/wait protocol use the same open-boundary law. Triple
swap goes further: six ordinary pairwise cuts correlate three participants, and mutual causal
support makes their three Faces one SCC and hence one joint Face.

This is evidence that n-party atomic synchronisation need not imply an n-party primitive.

## Cells reveal a different shape

The first direct cell encoding uses open state-transition Strands:

```text
Empty --put(v)--> Full(v)
Full(v) --take--> Empty
```

When an explicit initial state participates, `together` discovers an ordinary directed causal
chain. Scarcity and typestate follow naturally. Stable observation can instead consume only
positive value knowledge, leaving the state authority framed and adding no causal edge.

However, `put` plus `take` alone may close cyclically and SCC-normalise to a joint action. That is
exactly the correct Worlds answer for those two open transition geometries; it is not a satisfactory
model of a persistent shared cell with no initial state.

The leading next hypothesis is therefore:

```text
persistent cell / MVar
    = recurrent grounded participant owning hidden exact state
      + ordinary open request/reply protocol
```

whereas a linearly owned cell value can be threaded explicitly with `and_then`. This would preserve
Relay democracy while preventing state provenance from being mistaken for rendezvous willingness.

## `together` is generic open composition

The current examples show three outcomes of the same operator:

- mutual support -> rendezvous SCC -> joint Face;
- asymmetric support -> directed cell-state chain;
- no support between subgraphs -> causal incomparability.

Consequently `together` should not be specified as “run these in parallel”. It asks for lawful
sibling closure. Parallelism is an observation available to later physicalisation where the
resulting Geometry is incomparable.

## Knowledge-directed residualisation

Positive knowledge may remove alternatives before the airlock. Conversely, `Unknown` cannot be
used as negative readiness evidence. The physical side should receive only uncertainty and
obligations which remain after semantic establishment, not a scheduler-shaped replay of semantic
search.

## Liveness remains separate

Required source coverage in this lab is a finite closure-question condition, not a fairness or
progress guarantee. Starvation freedom, eventual service and physical scheduling remain separate
future pressures. A semantic liveness promise may become an obligation for physicalisation without
turning a scheduler into programme meaning.


## Grounded owner result

The direct-state falsifier led to a different decomposition for persistent shared state. Client
operations stay ordinary open events, but the state transition is grounded before sibling closure:

```text
exact state authority
       | and_then capture
       v
state-specific owner transition  <->  ordinary client request
       |
       v
next exact state authority
```

The owner family is reusable; state support selects which handler alternative survives. This is not
a lock semantic and does not alter `together`. It also explains why a one-place buffered channel is
just MVar vocabulary. The surviving request continuation remains exact causal frontier, not runtime
scheduler state.

## Dynamic exact identity

The fresh-endpoint pressure uses an imported exact Point. This exploits an existing Worlds law:
`Close` may substitute local Points, but a target Point not owned by any closure part is rigid and
must already be exact-equal at the source coordinate. Fresh channel identity therefore needs no
string equality and no new nominal carrier.

This result should not be confused with encoding protocol descriptions as Points. The latter was
rejected. Imported endpoint identity is a genuine exact identity supplied by the surrounding live
world; protocol role/meaning remains Presentation + Theory.
