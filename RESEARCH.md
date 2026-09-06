# Research notes

The interesting claim here is not that graphs, worlds, linear resources or fresh names are new. They are not.

The interesting possibility is that this particular geometric factorisation explains a surprisingly broad set of things usually given separate semantic machinery.

## The compression

```text
World   where authority is local and where actual history grows
Point   what identity is involved
Strand  which occurrence / possession exists
Face    what transformation happens
```

Detached Worlds are reusable possibility. `develop` grafts one possibility into a local actuality.

This currently gives executable accounts of functions, higher order, generativity, captures, modules, separate compilation, choice, joins, concurrency, continuations, handlers, recursion, existential identity and lifecycle retirement without introducing semantic objects named after those features.

That does not prove a foundational result. It does make one worth looking for.

## Why the compiler implications are interesting

### Locality

Authority is World-local. A development in `W` does not search unrelated actual Worlds for supply.

This suggests a compiler that works independently until incidence proves coordination is needed.

### Parallelism

Detached World components can be elaborated, certified, canonicalised and cached independently. Inside each World, the original Point/Strand/Face incidence still admits fine-grained parallel work.

A target theorem is:

```text
resource-disjoint developments commute up to fresh renaming
```

If true, parallel compilation follows from semantics rather than from a separate dependency analysis.

### Semantic ABI stability

A component's meaningful boundary is its canonical geometric frontier.

```text
World M
├── frontier unchanged
└── private child changed
```

If the frontier is unchanged, clients have no semantic incidence into the private change. This suggests:

```text
semantic ABI stability = frontier equivalence
```

Machine layout and calling convention remain later lowering concerns.

### Incremental compilation

The same membrane can be an invalidation boundary. A private edit should propagate only until the first changed frontier or Point-identity relation.

That gives ABI stability, information hiding, incremental recompilation and separate compilation the same underlying explanation.

### Separate custody

Provider archetypes can remain provider-owned while client code shares only Point identity and frontier geometry. That may be useful for distributed compilation as well as ordinary modules.

## Fibers as a demanding application

Fibers is part of the reason this project exists. Its V1 core grew from CML-style events into a language of complete concurrent possibilities, resource participation, proof frontiers, custody and continuing consequences.

A useful informal correspondence is:

```text
Fibers possible action        detached World geometry
commit                        development into actuality
resource participation         Strand authority
transactional interaction      Face geometry
proof frontier                 World frontier
continuing consequence         actual child World / resident authority
custody                        World locality
```

These are not yet formal translations, but Fibers gives the kernel a serious target: static geometry should make the runtime's dynamic search smaller and more explicit, without compiling away genuinely dynamic arbitration.

## What would make this a strong research result

Encoding many features is not enough. Universal formalisms can encode almost anything.

The stronger test is whether important properties become inevitable consequences of the representation.

Examples we already see experimentally:

- generative identities differ because developments graft fresh Worlds;
- detached futures cannot secretly capture remote authority because realised Strands cannot be hidden anchors;
- unchosen branch uses do not count because they never become actual;
- private implementation edits stop at unchanged frontiers because no client incidence crosses the membrane.

The next step is to turn these observations into short theorems.

## Research programme

The most valuable formal results would be:

1. actual-subcomplex preservation under development;
2. freshness of generated Worlds and identities;
3. locality of development;
4. custody / no authority teleportation;
5. scarcity and provenance preservation;
6. non-interference of disjoint developments;
7. retirement safety;
8. finite-choice normalisation, followed by a factorised version;
9. a representation or adequacy result for a small resource-sensitive higher-order calculus.

The nearby literature is rich: proof nets and interaction nets, bigraphs, possible-world and nominal semantics, open systems, graph rewriting, linear/ownership systems and module semantics all contain pieces of this picture. Any novelty claim should concern the particular factorisation and its derived properties, not the ingredients individually.

## Research posture

The kernel should be easy to break if it is wrong.

Hard cases should either:

```text
fall out of existing geometry
strengthen a general law
or remain explicitly unresolved
```

They should not disappear into feature-specific metadata merely to preserve the aesthetic of a tiny core.
