# Concurrency discovery arena

This arena asks how far Relay control and concurrency follow from the existing computation algebra
before Back, Live or a physical scheduler exists.

It imports rather than duplicates the promoted work:

- finite Package/Family/Development composition from `development_calculus/`;
- recurrence and stable recursive Judgement from the neighbouring computation laboratories;
- `form` / `perform` from `formed_computation/`;
- ordinary Worlds `Close`, Construction, correspondence and SCC normalisation.

There is no concurrency evaluator.

## Shared composition vocabulary

Facilities export ordinary Packages. They do not wrap Relay's composition words:

```text
choice      unordered semantic alternatives
or_else     stable dominance between alternatives
and_then    dependent composition; exact captures alone add causality
each        positive sibling coexistence without sibling supply
together    sibling open composition through ordinary Worlds Close
form        inert portable computation meaning + exact captures
perform     ordinary Context composition
```

The arena now includes channels, triple swap, grounded and recurrent IVar/MVar state, a one-place
buffered channel, semaphores, latches, barriers, CAS, an actor turn, cancellation, external readiness
and event-shaped formed computations, all using this vocabulary unchanged.

## One candidate representation of openness

The previous positive `match signature` object has been removed. The current representation is
smaller and more general:

```text
Geometry
    ordinary exact public Strands

open-boundary Presentation
    which public authority Strands may be used by sibling closure
    which offered sources, if any, are required by this closure question

Theory
    positive meaning supported on those Strand occurrences

Construction correspondence
    transports that meaning through identification and annihilation
```

`together` knows no channel, cell, send, receive, signal or triple-swap vocabulary. It selects
candidate cuts from the open presentation, asks Worlds for exact lawful closure, combines Theory on
identified correspondence classes, rejects contradiction and hides vanished support.

`OPENNESS.md` records the representation experiments and the reasons two tempting alternatives
were rejected; `STATEFUL.md` records the grounded IVar/MVar, buffered-channel, heterogeneous-choice
and exact-endpoint findings. `FURTHER.md` records productive recurrence, exact Point parameters,
token-topology primitives, CAS, actor/cancellation/external-readiness and the first liveness and
weak-memory pressures. `REFLECTION.md` synthesises what all fifty pressures imply for Relay's
open-composition model and records what should remain research scaffolding.

## Synchronous rendezvous

A sender and receiver are ordinary two-sided open actions. Offer/ack knowledge is supported on the
corresponding open Strands. The selected cuts identify that meaning through Construction
correspondence; the two Faces form one causal SCC and Worlds normalises the rendezvous to one joint
Face. `each` leaves the same siblings independent and open.

The same geometry can carry an extra exact scarce resource occurrence. Its Point identity passes
from sender ingress to receiver egress, so value communication and capability handoff use one
composition mechanism.

## Three-party rendezvous

`triple_swap.swap` is an ordinary Package with three equal-interface role alternatives. Each role
has only pairwise open inputs and outputs. Positive group knowledge correlates the pairwise seams.
Three compatible participants therefore establish six pairwise cuts whose three Faces form one
SCC and normalise to one joint Face.

Two participants cannot complete it; four cannot leak into a malformed three-party commit. `swap`
itself remains ordinary meaning usable under `choice`, `or_else` and Package transport. No
three-way carrier, leader, transaction object or scheduler is semantic data.

## Dependent `and_then`

A tentative rendezvous result may determine which new Form root exists on the RHS. The dependency
is an ordinary positive relation rather than a host callback. `and_then` specialises that relation
per tentative LHS alternative; `perform` then composes the selected target.

Constructing the Form adds no causal Face. Residual exact LHS authority remains ordinary capture
and creates causality only if the chosen target consumes it. An `or_else` pressure further proves
that a locally viable preferred rendezvous cannot commit if its dynamically formed complete
descendant is later refuted.

## Cell pressures

The direct cell experiments deliberately separate several ideas which are often bundled together:

- `empty -> put -> take` can be a directed exact state-transition chain;
- cell identity and empty/full typestate are positive Strand-supported meaning;
- one scarce exact state occurrence cannot satisfy two destructive takes;
- stable positive knowledge about a full cell can feed several readers without state capture or
  causal edges;
- a linear read which consumes/reproduces exact state authority does serialise, yielding alternative
  causal orders;
- channel receive and cell take can inhabit the same ordinary `choice` / `or_else` without an
  adapter.

The experiment also found a useful falsifier: bare `put` and `take` state transitions can mutually
close as an ungrounded SCC. That is lawful Worlds Geometry, not the desired shared-cell contract.

The follow-up owner experiment now tests the stronger representation. Exact persistent state is
grounded first by ordinary causal capture; only then is a request opening offered to `together`:

```text
state + request -> next_state + reply
```

The client request remains an ordinary event-shaped Package. Empty IVar state cannot satisfy
`await`; one `put` establishes Full exactly once; positive Full knowledge can feed several stable
observers without capturing the state authority. The same owner family gives MVar Empty/Full
recurrence without allowing bare `put` / `take` requests to self-ground.

A one-place buffered channel is then literally the MVar protocol: `send = put`, `recv = take`.
No buffer or channel-state semantic object is introduced.


## Dynamic exact endpoint identity

The laboratory string channel names are no longer the only identity experiment. Worlds supports a
more exact representation for dynamically created endpoints: mint a fresh exact Point and import
that Point into the relative open seam rather than owning it inside the action Geometry.

`Close` already treats imported target Points as rigid. Two seams carrying the same minted Point
therefore rendezvous; two independently minted Points have no solution. After a complete
rendezvous the private exact endpoint identity need not survive in result Geometry.

This suggests a clean eventual split: portable Package meaning describes an endpoint parameter;
Live/instantiation supplies its fresh exact Point. Exact runtime identity therefore need not become
a string, hash or Package-global nominal constant.

## Democracy

The strongest tests are heterogeneous. The same generic `together` can contain an independent
channel rendezvous and cell transition chain; it preserves their lack of causal relationship.
Likewise one `choice` may contain `recv(channel)`, grounded `take(mvar)` and an event-shaped
computation which has genuinely passed through `form` / `perform`. A channel peer or MVar owner
selects its complete descendant through the same `together` law. `or_else` uses exactly the same
stable-refutation rule across facilities.

A facility has failed the Relay democracy test if it needs its own versions of `choice`,
`or_else`, `and_then`, `each`, `together`, `form` or `perform`.

## Scheduler airlock

The arena retains the rule:

> Residualise uncertainty, not concurrency.

Whole-network and staged cooperative discovery produce the same final Package when they establish
the same hidden public Development. Independent rendezvous remain causally incomparable. Fully
known networks contain no task, blocked/runnable, wait-queue, programme-counter, channel-runtime or
scheduler state merely because their source was concurrent.

Physical scheduling belongs on the other side of the Back airlock unless unresolved semantic,
external or physical uncertainty genuinely requires residual coordination.

## Current scope

The arena has fifty executable pressures. `PRESSURES.md` records the remaining hostile questions.
The largest unresolved themes are larger symmetric participant pools, Membrane-local actor placement,
structured cancellation, a proper liveness-obligation account, a full weak-memory outcome doctrine
and finally Back residualisation.

Run with:

```sh
LUA=lua5.1 speculation/relay/computation/concurrency_discovery/run_lab.sh
```

or as part of:

```sh
make relay-check
```
