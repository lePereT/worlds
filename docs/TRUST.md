# Trust model

**Status: maintained implementation and public-API contract for the trusted in-process profile.**

Worlds is an in-process semantic kernel. Its ordinary clients are trusted code
such as Relay and Fibers, not mutually hostile tenants. The implementation
therefore protects semantic authenticity and validates new semantic claims, but
it does not repeatedly copy already-authentic immutable-by-contract data merely
to defend against deliberate caller mutation.

## Authentic Worlds values

Membranes, Points, Strands, Faces and Geometries are authentic only when
manufactured by Worlds. Private state is held in weak-key tables owned by the
module; protected metatable labels are descriptive and are not identity.

Construction, Presentation, Question and Refutation use the same private-state
shape. This was chosen after measuring both weak-key registries and closure
accessors. On the available TexLua runtime, a single closure accessor was about
34% slower on hot state reads and used about 30% more heap for 50,000 objects.
The weak-key representation is therefore the default rather than maintaining a
second encapsulation idiom for edge values.

## Borrowed finite arrays

Finite Lua arrays crossing the Worlds API are **borrowed read-only arrays**.
Worlds validates their required shape and semantic membership, but does not
clone them for ownership isolation.

This applies to, among others:

- Point incidence supplied to `Builder:strand`;
- Face input/output incidence supplied to `Builder:face`;
- carrier and boundary arrays returned by Geometry accessors;
- `W.points`, `W.inputs` and `W.outputs`;
- Construction parts and its normalised equation view;
- Presentation rows;
- Question sections, seeds and admissibility views;
- Refutation reasons; and
- optional History event arrays.

A caller must not mutate an array after passing it to Worlds while a Worlds
value retains it, and must not mutate an array returned by Worlds. Deliberate
mutation is outside the supported contract and may corrupt later semantic
operations. Clients which require an owned mutable table should copy explicitly
at that boundary.

The same rule applies to nested tables in returned evidence where documented as
a borrowed view.

## Validation

Trust does not relax the semantic laws. Worlds still validates newly introduced
claims, including:

- dense finite input sections;
- carrier kinds and Geometry membership during construction;
- producer/consumer scarcity and causal Geometry laws;
- boundary-equation legality;
- finite Question sections, admissibility and seeds; and
- strict join-lawfulness of every public constructive Question witness.

The implementation does not revalidate or clone an authentic immutable-by-
contract value merely because it crosses another internal module boundary.

Canonicalisation is not considered defensive copying. Worlds may allocate a new
finite representation when it actually changes representation, for example to
normalise equation records or canonicalise set-like Question sections by exact
boundary order.

## Threat model

Worlds does not attempt to defend against code in the same Lua process which
intentionally mutates borrowed arrays, abuses the `debug` library, tampers with
module internals or otherwise violates the API contract. Such code already has
sufficient authority to subvert the process.

This trust boundary is deliberate. The intended safety property is semantic
correctness between cooperating in-process components, not isolation between
adversarial Lua principals.

## Performance consequence

The trust contract is also a work contract. Re-observing an authentic value must
not allocate an owned copy merely because it crosses an API boundary, and a
trusted development must not be incidence-validated twice before it can be
admitted. `tests/mechanical-work.lua` ratchets those properties by deterministic
work rather than elapsed time.
