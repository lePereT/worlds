# Reflection after fifty concurrency pressures

The arena began by asking whether Relay needed a concurrency semantics. After fifty pressures the
more useful answer is that concurrency is exposing the shape of Relay's general open-composition
semantics.

The strongest result is not a catalogue of primitives. It is a small set of distinctions which keep
surviving every primitive family:

```text
exact occurrence        Geometry
positive description    Theory
permission to connect   open Presentation
alternative meaning     Family
composition             and_then / each / together
first-class openness    form / perform
persistent evolution    recurrence
physical obligation     downstream of the Back airlock
```

No pressure so far has justified a Task, Scheduler, Blocked state, ChannelState, CellState,
SelectState, transactional log, event carrier or memory-order effect carrier in portable semantic
meaning.

## 1. Concurrency is not one geometry

The experiments now contain several fundamentally different causal shapes:

```text
synchronous rendezvous
    mutual support -> SCC -> one joint Face

triple swap
    pairwise seams -> three-way mutual SCC -> one joint Face

persistent state
    grounded state -> directed transition -> next grounded state

barrier
    independent arrivals -> coordinator -> independent releases

semaphore
    independent scarce token transfers

latch
    independent countdown evidence -> one positive all-evidence continuation

actor turn
    mailbox state + actor state -> dependent handler -> renewed state

independent atomics
    incomparable per-location state histories

release/acquire
    explicit extra authority -> cross-location causal path
```

A language which represented all of these as "tasks which block and wake" would erase exactly the
structure Worlds makes available to later optimisation and physicalisation.

The reusable abstraction is therefore not a scheduler-shaped operational account. It is the open
Development from which the actual causal geometry can be discovered.

## 2. `together` is not fundamentally a parallel operator

The most important reinterpretation in the arena is `together`.

`each` says that sibling Developments coexist positively without supplying one another.
`together` says that sibling open boundaries may be lawfully composed.

The result may be concurrent, sequential, mutually synchronising, partly ordered or fully closed.
Those are observations of the resulting Geometry, not modes selected by `together`.

This makes `together` useful well beyond conventional concurrency. A Context hole, a rendezvous
seam, a reconstruction hole, a resumption boundary and a Foreign call boundary may all be instances
of the same open-composition question if later pressures continue to support that collapse.

## 3. The open boundary appears to have four irreducible aspects

Two attempted simplifications failed usefully.

First, encoding protocol description with additional Points polluted exact Geometry with descriptive
state and amplified graph symmetry. Second, treating positive Theory on a Strand as implicit
permission to close it made knowledge confer connectivity.

The surviving decomposition is:

```text
Geometry
    what exact occurrence exists

Theory
    what is positively known about that occurrence

open Presentation
    whether this composition question may or must connect it

Construction correspondence
    how occurrence meaning is transported through exact quotienting and annihilation
```

This is small, but the distinctions are real. In particular:

- knowledge is not authority;
- description is not permission;
- permission does not create an occurrence;
- a vanished exact image can still have a meaningful Construction correspondence class.

The last point is why the 0.6.6 Theory and concurrency lines fit together. Rendezvous may annihilate
its seam, yet the positive meaning supported on the identified source occurrences must meet before
being hidden. Construction correspondence supplies exactly that evidence.

## 4. Persistent state has provenance; rendezvous does not

The direct Cell experiment was an important falsifier. If `put` is merely an Empty->Full open
transition and `take` is Full->Empty, the two operations may mutually support one another and form a
lawful SCC with no initial Cell state.

That is not a defect in Worlds. It is the geometry which was presented.

The correction is conceptual:

```text
rendezvous
    participating actions may ground one another

persistent state
    current state authority must already be grounded
    before a client request may consume/advance it
```

IVar and MVar therefore use a persistent owner whose exact state authority is captured causally
before the request seam is offered to sibling closure. The client remains an ordinary open event.
The owner remains ordinary recurrent Development.

This distinction also explains why a one-place buffered channel is merely MVar vocabulary. Buffering
is persistent state; unbuffered rendezvous is mutual synchronisation. They need not share an
implementation mechanism merely because both are called channels.

## 5. Exact dynamic identity belongs on the exact side

The arena initially used portable string identities because they were convenient for Theory and
canonicality experiments. The later Point-parameter pressure found the cleaner runtime account.

A portable Package may contain a symbolic Point slot. Instantiation supplies a fresh exact Point from
the live environment. The action refers to that Point without owning it. Worlds already treats such
imported Points as rigid during Close.

Therefore exact endpoint identity can be genuinely nominal without introducing a nominal semantic
carrier:

```text
portable protocol meaning
        + symbolic exact slot
                |
                v instantiate
          fresh exact Point
```

Same Point closes. Different freshly minted Points do not. Once the private seam is closed, the
identity need not remain in result Geometry.

This pattern is likely useful beyond channels: object identity, Foreign handles, device identity and
other live resources may want the same portable-parameter/exact-import split.

## 6. Many familiar primitives collapse into topology

Several apparent state variables disappeared under pressure:

- semaphore capacity is N scarce token occurrences, not an integer counter object;
- latch completion is positive possession of all N arrival tokens, not observation that a counter is
  zero;
- cancellation is consumption of the exact residual authority required to continue;
- a known fair turn schedule may be finite cyclic topology rather than a scheduler state machine;
- per-location atomic order is exact state-authority causality, not an implicit global total order.

This does not mean every implementation must literally use those shapes. It means those shapes are
sufficient semantic contracts. Back remains free to refine them to counters, queues, locks, CAS
loops, static schedules or hardware instructions when that is the appropriate physical
realisation.

## 7. Positive Theory is especially valuable in concurrency

Concurrency APIs are full of dangerous negative questions:

```text
is nobody ready?
is the queue empty?
has no participant arrived?
did no other branch win?
```

Relay's Hit / Retry / Unknown distinction refuses to turn lack of current evidence into semantic
absence.

The successful primitives therefore prefer positive certificates:

- a Full IVar occurrence carries the published value;
- a latch has all required arrived tokens;
- CAS success has positive current=expected knowledge;
- CAS failure becomes eligible only after that preferred equality-constrained descendant is
  positively refuted;
- external readiness remains an open environmental boundary rather than becoming false merely
  because no peer is presently in the finite network.

This looks like a deep advantage of the restrictive positive Theory doctrine, not merely a proof
engineering convenience.

## 8. Liveness is the first large thing which does not collapse into finite viability

The arena can describe a cyclic turn-taking topology and can establish finite prefixes of it. That
does not prove that an infinite physical execution eventually grants every promised turn.

This should remain a separate notion.

The likely airlock contract is:

```text
semantic Development
    what behaviours/causal structures are lawful

liveness obligation
    what progress must eventually be delivered

Back
    chooses a physical realisation satisfying both
```

A completely known cyclic topology may discharge its liveness obligation with a static schedule and
no generic scheduler. A dynamic pool may require residual policy. The policy belongs downstream;
the promise may still be semantic.

Trying to encode fairness by bounded semantic search would be a category error.

## 9. Weak memory is likely the hardest remaining semantic pressure

The first atomic pressure establishes only the lower bound:

- operations on distinct locations remain incomparable;
- same-location state authority orders the operations which actually advance that location;
- release/acquire can be represented by explicit synchronisation authority creating a causal path.

That is enough to reject accidental global sequential consistency. It is not yet an allowed-outcome
model for C11 or Wasm.

The next serious step should use litmus families rather than invent memory-order tags first. For each
litmus, ask which semantic Development alternatives ought to remain lawful and which additional
ordering/publication authority rules them out. Only then should Relay decide whether ordering is
best represented by library protocol meaning, exact Geometry, Theory constraints, or a physical
Back obligation.

## 10. The airlock principle has become more precise

"Residualise uncertainty, not concurrency" still holds, but the arena suggests a slightly fuller
version:

> Physicalise established Geometry directly. Residualise only unresolved choice, open environment,
> outstanding liveness obligations and physical ordering constraints which semantic knowledge has
> not discharged.

The semantic search procedure itself is never something Back has to replay. Whole-network and staged
cooperative discovery already produce the same canonical meaning in the cases tested.

A scheduler is therefore not the implementation of Relay concurrency. It is one possible physical
mechanism for a residual problem which may or may not exist after semantic establishment.

## 11. What should be promoted, and what should remain research scaffolding

The following ideas now have repeated independent pressure behind them:

- universal composition vocabulary;
- open-boundary Presentation distinct from Theory and authority;
- occurrence-relative Theory transported through Construction correspondence;
- imported exact Point parameters for live nominal identity;
- grounded recurrent ownership for persistent state;
- liveness kept distinct from finite viability;
- no implicit global ordering for independent state.

The following should not yet be promoted as final Relay law:

- the record-shaped `support.strands` doctrine used by the lab;
- the exact spelling/shape of `authority.open.required_outputs`;
- the particular recurrent-owner encoding used here;
- the one-place actor construction;
- cancellation propagation policy;
- any complete claim about fairness or weak memory;
- the current exhaustive Close/canonicalisation algorithms for large symmetric pools.

Those are useful witnesses, not yet constitutional surface.

## 12. The deeper unification

The original hope was that channels, cells and other primitives would obey Relay's democracy. They
do. The stronger possibility is now visible:

```text
function application
rendezvous
persistent-state request
barrier participation
resumption
focus reconstruction
Foreign interaction
```

may differ primarily in the Development they present at an open boundary, not in the mechanism used
to compose them.

If later pressures preserve this, Relay will not have a concurrency subsystem sitting beside its
function, state and control semantics. It will have one geometry of open composition, with
concurrency as one of the richest things that geometry can express.

That is the main result of the arena so far.
