# Grounded state and exact identity findings

This round pressures five consequences of the open-boundary model without adding a scheduler,
blocking state or facility-local composition algebra.

## 1. IVar / promise

The useful representation is not a bare Empty/Full rendezvous seam. A persistent state occurrence
is grounded first, then captured causally into the state-specific owner transition. Only the
request/reply seam is offered to `together`.

```text
Empty authority
      | and_then capture
      v
Empty owner + put request
      |
      v
Full(value) authority
```

An empty IVar cannot satisfy `await`. One put establishes Full exactly once. Once Full, positive
value knowledge can feed several stable observers without consuming the state authority or adding
Faces. A linear `await` remains available when an actual operation/resumption frontier is needed.

## 2. MVar

The same owner family has three state-specific handlers:

```text
Empty + put(v)  -> Full(v)
Full(v) + take  -> Empty + v
Full(v) + read  -> Full(v) + v
```

The state input is captured before request closure. Bare put/take client requests therefore cannot
mutually self-ground. The surviving state authority can be fed back into the same owner family for
the next step, giving the recurrent Empty/Full protocol without a lock or `CellState` object.

The finite owner family is now paired with `recurrent_owner.lua`, which packages persistent Empty/Full
ownership as finite productive cyclic topology. Unfolding is an observation of finite prefixes, not retained
runtime execution history. Live will still need to advance the current exact boundary rather than replay
semantic unfolding.

## 3. One-place buffered channel

No new representation was needed:

```text
buffer.empty = mvar.empty
buffer.send  = mvar.put
buffer.recv  = mvar.take
```

A send may complete while no receiver exists, leaving Full state. A second send has no descendant
until a receive returns the state to Empty. This is a buffered channel obtained by library naming,
not hidden channel runtime state.

## 4. Heterogeneous selection

An event-shaped computation which genuinely passes through `form` / `perform` has the same public
frontier arity as channel receive and MVar take. All three may therefore inhabit one ordinary
`choice` family.

A channel sender leaves only the rendezvous descendant. A grounded Full MVar owner leaves only the
MVar descendant. The formed event remains an ordinary third alternative; no `SelectState` or
facility adapter is introduced.

This also clarifies that a common causal frontier is meaningful semantic structure. Removing every
continuation occurrence merely to make operations smaller would weaken ordinary `and_then` and
heterogeneous event composition.

## 5. Fresh exact endpoint identity

Worlds already contains the exact identity mechanism needed by dynamically created channels.
`W.minter()` creates a fresh exact Point. A relative send/receive action may reference that Point in
its Strand incidence without owning it.

For `Close`, a target Point not owned by any closure part is rigid: the corresponding source
coordinate must already contain the same exact Point. Therefore:

```text
mint a; send(a) + recv(a)  -> one rendezvous
mint a; mint b; send(a) + recv(b) -> no solution
```

Even two Points minted with the same presentation name are distinct. After the private seam closes,
the endpoint Point need not survive in result Geometry.

This is distinct from the rejected protocol-Point experiment. Protocol descriptions should remain
Presentation/Theory. The imported Point represents genuine runtime identity supplied by the live
world.

The likely final split is:

```text
portable Package
    endpoint parameter / protocol meaning
          |
          v instantiate
exact Live world
    freshly minted imported Point
```

So exact endpoint identity need not be serialised as a string, hash or Package-global nominal name.

## Second-wave state consequences

The follow-up pressures sharpen the state taxonomy further:

- **semaphore:** N independent scarce tokens, not integer runtime state;
- **latch:** positive collection of N arrived tokens, avoiding a negative emptiness observation;
- **CAS:** a preferred equality-constrained state transition with ordinary fallback;
- **actor turn:** mailbox state and actor state are just grounded MVars composed with a dependent relation;
- **memory order:** exact per-location authority serialises only one location; explicit sync authority adds
  cross-location release/acquire causality.

Persistent owner topology is now also represented by a productive cyclic Package. The recurrence
plugger was strengthened so Strand-supported Theory survives recursive quotienting by the same
correspondence-before-hiding law used by finite composition.
