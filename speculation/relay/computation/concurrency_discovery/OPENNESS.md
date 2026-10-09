# One open-boundary contract

The concurrency arena now treats openness as a candidate Relay-wide abstraction rather than a
channel feature.

The current research decomposition is:

```text
exact authority boundary
        +
open-boundary Presentation
        +
occurrence-relative positive Theory
        +
Construction correspondence
```

The four parts have deliberately different jobs.

## Exact Geometry

Public authority inputs and outputs are ordinary exact Strands. Their Point incidence, Membrane
locality, scarcity and causal relationships are Worlds meaning. Protocol descriptions are not
encoded by manufacturing extra protocol Points merely to make matching work.

A short-lived experiment did exactly that. It made rendezvous possible, but protocol-only Points
survived as internal exact Geometry after closure and greatly increased canonical symmetry. The
experiment was rejected: descriptive protocol information should not become exact causal identity
unless the programme genuinely gives it such identity.

## Open-boundary Presentation

Not every known authority occurrence is offered to sibling closure. The lab therefore retains a
small non-authoritative Presentation selecting which public authority ports are open to
`together`. A source may additionally be required to participate in the current closure question.

This distinction is necessary. Pressure 34 demonstrates that positive Theory supported on an
occurrence does not by itself authorise a cut.

The Presentation confers no authority and carries no protocol meaning. It merely says which exact
boundary occurrences this composition question is permitted or obliged to connect.

The long-term hypothesis is that this same notion can replace several apparently different kinds
of opening:

```text
Context hole
channel rendezvous seam
Focus reconstruction hole
routine/resumption opening
Foreign call/re-entry seam
cell/server request opening
```

Those may retain different library vocabulary while sharing one semantic interface mechanism.

## Occurrence-relative Theory

Positive meaning is attached to the open Strand occurrence itself in this research calculus. A
channel offer can therefore carry facts such as protocol, channel identity and payload relation;
a cell-state occurrence can carry empty/full and payload facts.

The record-shaped support used here is only a compact laboratory doctrine. The architectural claim
is broader: an exact occurrence may support positive Theory. The final Relay doctrine need not use
record fields.

Knowledge constrains a candidate closure; it does not provide authority to make the closure.

## Construction correspondence

A selected rendezvous may annihilate the exact Strand which carried its interface meaning. Plain
`Construction:image` is then legitimately `nil`. Theory transport must nevertheless remember that
the two source occurrences were identified before disappearing.

`Construction:correspondence()` supplies exactly that quotient evidence. The arena therefore
transports Strand-supported knowledge through correspondence classes, combines knowledge on
identified classes, checks contradiction, and only then existentially hides classes which have no
public result occurrence.

This is a substantial convergence between the 0.6.6 Theory work and the concurrency work: no
special matcher transport law is required.

## `together` is broader than concurrency

The same generic operation now discovers three quite different shapes:

```text
rendezvous       mutual causal SCC -> one joint Face
cell protocol    directed state-transition chain
mixed network    independent subgraphs remain incomparable
```

So `together` is better read as generic sibling open composition than as a parallel operator.
Concurrency is one observation of the resulting Geometry.

## Persistent state is not merely rendezvous

The direct cell-state experiment is deliberately retained because it found a limit.

With an explicit initial state, `empty -> put -> take` is a normal directed chain. A stable view of
already-known full-cell knowledge can fan out without capturing the state Strand, whereas two
linear reads of the exact state authority serialise as two possible causal orders.

However, the bare direct-state encoding also permits `put(empty->full)` and
`take(full->empty)` to mutually close as a joint SCC with no initial state. Worlds is correct to
admit the Geometry: mutual support is exactly what makes rendezvous and triple swap work. The
library representation is what is under-specified.

This suggests a sharper distinction for future cell work:

- ephemeral synchronisation protocols may be entirely joint open closure;
- persistent shared state probably needs a grounded recurrent participant which owns the hidden
  state, while callers expose ordinary request openings;
- a linear state value owned directly by one computation can instead be threaded explicitly with
  `and_then`.

The follow-up owner experiment now confirms the useful half of that hypothesis. A state token is
first captured causally into a reusable server family; request/reply seams alone are then exposed to
`together`. Client `put` and `take` requests cannot self-ground, while the surviving exact state
authority feeds the next owner step. IVar is the monotone one-shot instance; MVar is the Empty/Full
recurrent instance. A one-place buffered channel is simply MVar vocabulary.

The current implementation still expands finite owner history in the research Package. A later Live
pressure should retain only the current exact boundary rather than treating historical growth as a
runtime state representation.


## Exact identity may live outside the relative Geometry

The endpoint-minting pressure adds another useful form of openness. Worlds permits a Strand to
reference an exact Point not owned by that relative Geometry. Such imported target Points are rigid
under `Close`: a candidate cut must already carry the same exact Point at that coordinate.

A dynamically created channel can therefore use a freshly minted imported Point as endpoint
identity. Same identity closes; a different fresh Point does not. This is distinct from the rejected
"protocol Points" experiment above: the Point represents genuine exact runtime identity, not a
protocol description, and neither send nor receive owns it as internal action Geometry.

This strongly suggests that portable open Package meaning should have an endpoint parameter while
exact instantiation supplies the minted Point. The current string channel names remain useful for
portable Theory/canonicality pressures, but they are no longer the leading runtime-identity model.

## Candidate constitutional laws

The experiments currently support these laws:

1. Knowledge about an occurrence does not authorise its use.
2. Declaring an opening does not add protocol meaning or exact authority.
3. Candidate closure is ordinary Worlds Construction; protocol compatibility is positive Theory.
4. Theory must transport through Construction correspondence before vanished support is hidden.
5. Mutual causal support is neither inherently good nor bad; the library contract determines
   whether an SCC is a rendezvous or an ungrounded state cycle.
6. Search/discovery history is evidence, never programme meaning.
7. Fully established concurrency leaves no scheduler residue merely because it was concurrent.

## Exact Point parameters

Dynamic endpoint identity exposed one additional form of boundary parameterisation. A portable
symbolic action may designate a symbolic Point slot whose exact occurrence is supplied by the live
instantiation context. Instantiation uses the external exact Point directly in Strand incidence and
does not make the action own it.

This is importantly different from creating a local Point and quotienting it with a handle later:
that local Point becomes ordinary owned Geometry and loses the rigid-import property. Exact
parameter substitution therefore belongs at the Presentation/instantiation boundary.

The result does not add a concurrency-specific identity carrier. It generalises the existing idea of
a relative Development whose exact environment supplies part of its boundary identity.
