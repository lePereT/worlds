# Changelog

## 0.6.6 — Construction correspondence and Lua 5.1 compatibility

### Construction evidence

- `Construction:correspondence()` exposes immutable, non-authoritative evidence
  of the exact quotient established by the ordinary join materialisation.
- Source classes remain available even when the identified class is later
  annihilated and has no result carrier.
- `correspondence:survivor(source)` returns the unique surviving target carrier
  of a marked source quotient class, or `nil` after annihilation; composed
  correspondences preserve the same source-to-final-target query.
- Correspondences compose across staged constructions with genuinely fresh
  later parts and support source-relative endpoint mating.
- `Construction:image` is unchanged and remains the simple surviving-carrier
  projection. `W.join` keeps its existing return values and does not retain
  correspondence evidence.
- Public Construction-class values are opaque evidence, are not Worlds carriers
  and confer no authority.
- `Construction.try_join(P,E)` provides non-exceptional judgement for well-formed
  client-supplied cuts: geometric incompatibility returns `nil, reason`, while
  malformed API use still raises. Strict `Construction.join` remains unchanged
  for callers which already possess lawful evidence.

### Lua 5.1 / LuaJIT repair

- persistent boundary sections no longer rely on table `__len`, `__pairs` or
  proxy-array iteration semantics;
- opaque persistent sequences retain path-based local updates internally;
- public Geometry sections are cached ordinary dense arrays with normal Lua 5.1
  `#`, numeric-index and `ipairs` behaviour;
- internal fast/query paths use explicit persistent-sequence operations;
- all shipped Lua is checked for post-5.1 syntax.

### Relay research laboratories

- removes the superseded `modern/computation_boundary_lab` and
  `modern/transactional_computation_lab`;
- promotes the restrictive Theory contract/lifecycle work to
  `speculation/relay/theory/`;
- promotes the package-first finite composition, recurrence, stable Judgement and
  Geometry-viability laboratories to `speculation/relay/computation/`;
- adds a Relay concurrency-discovery arena in which channel operations are ordinary open
  Packages and the shared `choice` / `or_else` / `and_then` / `each` / `together` algebra
  discovers synchronous and three-party rendezvous without facility-local composition wrappers;
- replaces the early match-signature prototype with ordinary exact open Strand occurrences,
  Strand-supported positive Theory and native Construction-correspondence transport, including
  lawful annihilation of the matched occurrence before public projection;
- adds cell/state pressures showing exact scarcity, typestate, stable knowledge fan-out,
  heterogeneous choice and the direct-state grounding falsifier, then follows that falsifier with
  grounded IVar/MVar owner transitions and a one-place buffered channel defined exactly as MVar
  put/take;
- adds a heterogeneous choice pressure containing channel receive, MVar take and a computation
  genuinely produced through `form`/`perform`;
- demonstrates fresh dynamic endpoint identity as an imported exact Point, using the existing rigid
  imported-Point law of `Close` rather than a string or Package-global nominal token;
- demonstrates dependent `and_then` in which tentative rendezvous knowledge selects a fresh Form
  root while descendant refutation still governs commitment;
- extends the concurrency arena to 50 pressures with productive cyclic persistent ownership, imported
  exact Point parameters, scarce-token semaphores, positive-evidence latches, directed barriers, CAS,
  actor turns, cancellation, open external readiness, cyclic turn-taking and first weak-memory ordering;
- strengthens recursive Context plugging so Strand-supported Theory and surviving open Presentation are
  transported through Construction correspondence before hidden recursive classes are projected;
- records liveness as a distinct downstream obligation rather than treating bounded viability or scheduler
  state as semantic progress evidence;
- fixes `Construction:image` for a lawful annihilated `nil` image returned through a
  cached Query Realisation;
- adds `make relay-check` as the executable Relay research entry point.

### Ontology and compatibility

No carrier or Geometry-changing primitive is added. Membrane, Point, Strand and
Face remain the complete Worlds ontology; `boundary`, `join` and `advance` keep
their existing semantic laws. The 0.6.4/0.6.5 public surface remains compatible.

## 0.6.5 candidate — small centre, disposable speed

- Restores the verified geometric centre to **350 lines** (369 including the exact construction-image witness), below the 0.6.1 kernel budget of 387 lines.
- Moves local-frame matching and single-Face live specialisation out of `_kernel.lua` into disposable `_fast.lua`; strict `join` remains their reference/fallback law.
- Keeps persistent boundary, compiled query, and borrowed-view acceleration at the edge for realtime use.
- Retains the refined quotient mechanics: cyclic induced Membrane quotients are rejected, and affected frame Membranes/Points are rematerialised so Construction images commute with surviving incidence.
- Adds an architectural size gate: the verified centre may not exceed the 0.6.1 line budget and may not import fast/query acceleration.
- Public behaviour remains compatible with the 0.6.4 candidate surface; Construction, Presentation, History and query machinery remain edge facilities rather than geometric ontology.


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
