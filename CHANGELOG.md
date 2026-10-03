# Changelog

## 0.6.4 — real-time mechanics and deterministic work ratchets

Worlds 0.6.4 preserves the 0.6.3 ontology and judgement laws. The release is a
mechanical/performance consolidation for trusted in-process clients such as Relay
and Fibers.

### Runtime mechanics

- authentic Worlds values are trusted after construction; finite arrays are
  borrowed read-only views rather than defensively copied;
- weak-key private state is the common encapsulation representation;
- successful Questions retain their strict-join realisation so clients do not
  prove/materialise the same exact candidate again at commit;
- one-part/no-equation construction is identity work;
- DSU singleton state is lazy and Construction images choose dense or sparse
  representation according to join shape;
- `W.development_builder()` defers trusted incidence checks to one authoritative
  `finish()` validation;
- `W.minter()` creates authentic exact Points without quotient composition;
- prepared live boundaries support frame-aware matching and local evolution;
- persistent boundary sections and disposable incidence/order indexes preserve
  unchanged frontier structure across local advances;
- indexed single-Face `advance` applies only the removed/added Strand delta;
- indexed `advance` also reuses the frame-local quotient for arbitrary small local Developments, then applies the resulting live-boundary delta without scanning unrelated authority;
- frame-local evolution now falls back to strict whole-frame join when the local quotient remaps a touched pre-existing Membrane or Point, because untouched authority may share that structural coordinate;
- retained frame-local Match evidence preserves matched pass-through sources which remain terminal/open in the joined world;
- Close uses a monotone arity/rigid-Point support filter before deeper finite
  relation search.

### Regression discipline

Wall-clock benchmarks remain evidence only. Release gates now include two kinds
of deterministic work ratchet:

- `tests/work.lua` guards finite Question/search work using solver fuel and VM
  instruction quanta where Question construction precedes the fuelled engine;
- `tests/mechanical-work.lua` guards copying/materialisation/locality properties,
  including constant-work borrowed observations, identity joins, retained
  realisation commit reuse, single-validation development construction and
  indexed local `advance` independent of unrelated live-frontier size, including multi-Face causal Developments.

The paired Fibers checkpoint adds its own exact edge-operation ratchets and is
used as an application-shaped validation of the release.

### Semantics

No new programme authority, resource kind or semantic operation is introduced.
Generic `join` remains the reference composition law and specialised evolution
is continuously checked against the existing semantic/differential suites.
