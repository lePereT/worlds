# Worlds 0.2.0

Worlds is a small executable semantic kernel built from four carrier objects:

```text
World    locality / actuality by containment
Point    semantic identity
Strand   one occurrence of authority
Face     causal transformation
```

Actualisation is defined by complete geometric attachment:

```text
actual boundary of K
        +
detached open patch P
        |
        v
     Att_K(P)
        |
 complete witness μ
        |
        v
      graft
        |
        v
fresh actual causal geometry
```

The complete attachment relation is semantic. Discovery order, search strategy and indexing are implementation concerns.

## Public surface

```lua
local Worlds = require('worlds')

Worlds.VERSION      -- "0.2.0"
Worlds.Model
Worlds.Attachment
Worlds.Certified
Worlds.Separate
Worlds.Frontier
Worlds.Completion
```

### Construct the carrier

```lua
local m = Worlds.Model.new('Actuality')
local O = m.actuality

local F = m:point('Fn', O, 'FnIdentity')

local D = m:world('demand')
local G = m:world('generated')

local gate = m:strand('call?', D, {F}, 'Call')
local out  = m:strand('out', G, {F}, 'Result')
m:face('body', G, {gate}, {out}, 'Body')
```

### Derive an open patch

Any suspended cell in the connected component can designate the same derived patch:

```lua
local P = Worlds.Attachment.patch(m, gate)
```

`P:inputs()`, `P:outputs()`, `P:demands()` and `P:cells()` are observations of derived topology. `Patch` is not a fifth carrier object.

### Query complete attachment

```lua
local K = m:world('call-site', O)
local call = m:strand('call', K, {F}, 'Call')

local q = Worlds.Attachment.query(m, K, P, {
  { demand = gate, supply = call },
})

local status, value = q:step(100)
```

Possible query results are:

```text
hit       value is one complete Witness
retry     value is a current emptiness Certificate
unknown   the retained solver has not yet decided
```

`unknown` is not Worlds semantics. A query can be resumed without restarting unless its relevant boundary changes.

The fixed binding above is merely an optional boundary constraint. It does not make `gate` a privileged semantic trigger.

### Graft a witnessed attachment

```lua
if status == 'hit' then
  local instance = Worlds.Attachment.graft(value)
end
```

Grafting revalidates the witness atomically, creates fresh generated identity, reconstructs incidence and leaves the detached patch unchanged.

A stale witness is rejected without partial mutation.

## Multiplicity

Worlds distinguishes:

```text
no complete witness
one complete witness
several complete witnesses
```

Several witnesses are not a kernel error. Worlds does not choose among them.

A retained query may expose a constructive witness as evidence of inhabitation; the order in which a solver discovers such evidence is **not** a semantic selection policy. A caller that commits one of several valid witnesses is making a choice above the attachment relation and must not rely on traversal order as part of Worlds semantics.

Selection, priority, fairness and scheduling are theories/programming constructs above attachment.

## Sibling order

0.2 makes the following constitutional:

> Sibling order is not causal order.

Search traversal, array position and serial ordering may help an implementation but cannot alter the existence or emptiness of an attachment.

Causal order must be represented by causal incidence.

## Search and performance

`Att_K(P)` is a semantic space, not an array that a runtime should construct eagerly.

The reference package supplies a retained fail-first query which can produce one witness or prove current emptiness without enumerating every witness. For example, the test suite finds one attachment in a case with 60,480 possible complete witnesses after only a handful of search steps.

The implementation deliberately permits small transparent indexes/caches where they make experimentation pleasant. Such structures are valid only when deleting them leaves the same attachment definition and proofs.

## Certification

`Worlds.Certified` still validates actual resource/provenance laws and every attachable detached patch before producing an immutable primitive snapshot.

Possible and actual geometry therefore continue to obey the same structural discipline.

## Separate compilation

`Worlds.Separate` and `Worlds.Frontier` remain geometry-derived artefact layers. Entry gates may still be useful artefact/indexing handles, but they no longer define actualisation.

The 0.2 tests exercise importing an opaque provider, deriving the imported open patch, querying it against client-local authority and grafting a fresh instance.

## Source layout

```text
src/worlds/model.lua                 four-object carrier
src/worlds/topology.lua              derived detached components/boundaries
src/worlds/attachment.lua            public Att(K) retained-query surface
src/worlds/graft.lua                 fresh actualisation of a witnessed attachment
src/worlds/audit.lua                 resource/causal certification
src/worlds/certified.lua             immutable certified observation
src/worlds/attachment_reference.lua  exhaustive test/research oracle (not public)
src/worlds/separate.lua              portable geometry
src/worlds/frontier.lua              artefact-level frontier abstraction
```

## Research boundary

0.2 deliberately does **not** promote the following experimental consequences into the carrier:

```text
residual attachment
conflict relation
independence relation
cubical concurrency cells
transaction object
Fibers combinators
quantum structure
```

The current experiments suggest several may be derived from attachment/open-process geometry. They remain research until formalised.

### What attachment may make possible

`Att_K(P)` deliberately stops below these programming and physical interpretations, but it exposes a common mathematical place from which several future constructions can be investigated without enlarging the carrier:

* **true concurrency** — exact residual attachments may derive causality, conflict, independence and cubical higher concurrency rather than storing those relations;
* **transactional concurrency / Fibers** — `choice`, `and_then`, `each`, `together` and certified fallback may be expressible as operations on open attachment families, composition and hiding;
* **incremental execution and compilation** — a proof that an attachment family is empty can expose exactly which boundary facts may invalidate that proof;
* **parallel realisation** — a derived independence cell could permit one semantic concurrent world to be scheduled sequentially, in parallel, or onto devices without changing meaning;
* **quantitative and quantum theories** — once the process/configuration geometry is established, probability, cost or quantum-process structure can be explored as enrichments above Worlds rather than ad-hoc carrier fields.

None of these is a 0.2 kernel promise. Their significance is precisely that attachment gives us a way to ask whether they are **derived structure**. See `RESEARCH.md` and `FUTURE.md`.

See `LAWS.md`, `RESEARCH.md`, and `formal/README.md`.
