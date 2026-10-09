# Second-wave concurrency findings

This round follows the open-boundary and grounded-state work through the next primitive families.
The important result is not that Relay can name more concurrency constructs. It is that they keep
falling into different small geometries over the same composition algebra.

## Productive persistent recurrence

A forever-server is not a pure least fixed point of completed computations: a bare unproductive
cycle has empty finite meaning. Persistent ownership therefore uses **productive recurrence**.
Each state root exposes its current grounded boundary as an ordinary finite alternative and may also
advance to another semantic root.

The cyclic Package stays finite while larger Kleene observations expose longer finite histories.
To make this representation compatible with the concurrency arena, recurrence plugging now uses the
same quotient law as finite composition: Strand-supported Theory is merged through Construction
correspondence before hidden classes are projected, and open-boundary Presentation on surviving outer
ports is preserved. The original 32 recurrence pressures remain green.

## Portable parameters and exact identity

The tempting bridge "instantiate a local Point, then quotient it with a live endpoint handle" was
rejected. Once the local Point is owned by the action Geometry, later exact composition is permitted
to identify it with another owned Point. That loses the nominal rigidity wanted for dynamically
created endpoint identity.

The successful bridge is smaller: symbolic Geometry instantiation may receive an external exact
Point for a designated symbolic Point slot. Strands may use that Point, but the instantiated action
does not own it. Worlds' existing rigid-import law for `Close` then does the rest.

```text
portable symbolic Point slot
          |
          | instantiate with exact import
          v
open action incident on live Point
          |
          +-- same Point peer  -> lawful closure
          +-- other Point peer -> no solution
```

This is Presentation/instantiation information, not serialised endpoint identity.

## Semaphore

A counting semaphore does not need a counter state machine. Capacity `N` is `N` scarce token
occurrences.

```text
available token --acquire--> held token
held token      --release--> available token
```

Two tokens satisfy two acquires. A third acquire has no Development. Release transfers the same
exact token back into the available pool. Capacity is topology.

## Countdown latch

A latch gave a useful answer to the danger of negative observations. Completion need not ask
"is the count zero?". Start with `N` available tokens; each countdown turns one into an arrived
token; `await(N)` requires all `N` arrived tokens.

Completion is therefore **positive possession of the complete finite evidence**, not inference from
absence.

## Barrier

A barrier is not the same geometry as triple swap. Each participant can publish its arrival before
the others. One coordinator Face requires all arrivals and produces release occurrences, after which
each participant continuation may proceed.

```text
arrive A --\
arrive B ---> barrier Face ---> release A ---> cont A
arrive C --/                  -> release B ---> cont B
                              -> release C ---> cont C
```

The result is directed phase synchronisation, not a mutual-support SCC. This keeps rendezvous,
barrier synchronisation and atomicity distinct.

## Compare/exchange

CAS needs no disequality primitive. The preferred branch says positively:

```text
current = expected
next    = desired
success = true
```

The fallback preserves `current` and reports failure. Ordinary `or_else` makes the fallback eligible
only when the equality-constrained preferred descendant is refuted. With a known mismatching value,
positive contradiction is enough to select failure.

## Actor turn

A one-place actor turn was built from:

- one MVar mailbox;
- one grounded MVar state cell;
- ordinary `each` to obtain message and state;
- a finite dependent relation for the handler;
- exact capture of only the actor-state authority which is advanced.

The mailbox returns to Empty and the actor state returns to Full with the new value. No Actor carrier
or actor-specific composition operator is present. Membrane-local placement remains a later pressure.

## Cancellation

Cancellation is not a control-state bit. A Form capture or continuation already contains exact
residual authority for continued participation. A cancellation action may consume that authority.
Worlds scarcity then makes "continue and cancel" impossible in one Development.

This does not yet define cancellation propagation policy; it establishes the representation of the
right being revoked.

## External readiness

An unavailable external peer is not semantic failure. Established internal work can be composed
with an unresolved external action using `each`; only the environmental seam remains open. A later
external peer closes that seam normally.

Thus external uncertainty can cross the airlock as an open boundary rather than dragging a generic
scheduler or wait-queue representation through semantic meaning.

## Progress and fairness

Known turn-taking can be finite cyclic Package topology. The arena constructs an A/B recurrent turn
protocol with no scheduler object.

But finite positive Development prefixes do not prove that an infinite execution eventually takes
the next turn. That is an intentional boundary: **eventuality is a liveness obligation**, not a fact
which this finite viability calculus should fake by bounded search. Back may satisfy a known liveness
obligation with a static cyclic realisation; dynamic fairness may require residual scheduling policy.

## First weak-memory pressure

Relay must not silently impose global sequential consistency. Two atomic operations on distinct
state authorities remain causally incomparable. Per-location state authority orders operations only
where the same cell actually participates.

A release/acquire relationship is an explicit extra sync authority occurrence. Capturing that
occurrence creates the cross-location causal path.

This is only the first memory-model pressure. It establishes where ordering can live; it does not yet
claim a complete C11/Wasm allowed-outcome model.

## Remaining hard edges

- six-participant triple-swap pools still pressure canonicalisation/search rather than semantics;
- Membrane-local actor/mailbox placement has not yet been made normative;
- cancellation propagation and structured cancellation scopes remain open;
- liveness needs a proper obligation/refinement account;
- a full weak-memory outcome doctrine and its Back refinement are still ahead;
- Back residualisation remains deliberately downstream of these semantic pressures.
