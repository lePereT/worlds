# Worlds

**Version 0.1.0**

A small geometric kernel for identity, authority, transformation, locality and unrealised computation.

The current ontology is deliberately tiny:

```text
World   locality, custody, actual ancestry, fresh-instance boundary
Point   semantic identity
Strand  one occurrence / possession / authority
Face    transformation
```

There is one distinguished actuality World, `Ω`.

A World is **actual** when its parent chain reaches `Ω`. A detached World component is reusable possibility. Computation is the local act of grafting such a possibility into actuality:

```text
        detached                           actual

        D     G                              Ω
         \   /                               |
          stage          develop(u)          W
                                               \
                                                G@u
```

The important asymmetry is:

```text
identity may be shared or glued;
authority must move.
```

Points may identify the same thing across Worlds or even across compiler custody. Strands do not thereby become available elsewhere. Authority crosses a membrane only through ordinary Face geometry or through the open frontier of a development.

That distinction has turned out to explain rather a lot.

## How this came about

The longer arc began with Fibers. It started as a CML implementation and gradually became a language of complete concurrent possibilities, resource participation, custody and continuing consequences. I wanted a good static substrate for that system, but none of the obvious static languages — Rust, Zig, Odin, Swift — quite matched the semantic shape I wanted. Relay began from a simple conviction: represent computation honestly rather than representing a particular computer dishonestly; better semantics can make code simpler **and** leave more room for efficient representation. Relay's kernel then moved through standard proof objects, the five-form calculus, the labelled 2-complex, and finally Worlds.

The 2-complex was the decisive step:

```text
Point   identity
Strand  occurrence
Face    interaction
```

Point gluing became semantic commitment. `DELTA` and `EPSILON` became ordinary Faces. Scarcity and provenance became incidence facts. The problem was openness: functions, modules, generics, continuations and separate compilation describe geometry which matters before all of its surroundings exist.

Worlds are the current answer to that problem. They keep the Point/Strand/Face geometry and add one orthogonal notion: **where authority is local, and whether geometry is attached to actuality yet**.

## The kernel in one picture

```text
                        stable identity
                              ●
                             / \
                            /   \
                  actual call   detached gate
                      |              |
                      |              |
                  authority      open demands
                      |              |
                      └──── develop ─┘
                              |
                              v
                        fresh child World
                              |
                         ordinary Faces
```

`develop(trigger)`:

1. finds a unique compatible detached gate through shared Point identity;
2. discovers the suspended stage around it;
3. matches open demands only against unspent authority in the trigger's World;
4. resolves prospective input use-sites and rejects non-linear aliasing before mutation;
5. grafts fresh generated Worlds below that World;
6. reconstructs ordinary Point/Strand/Face incidence;
7. leaves the detached archetype unchanged.

No latency counter, Event object, capture set, polarity flag, binding table or callable object is needed by the kernel.

## What currently falls out of the same geometry

The reference experiments cover:

```text
future                 detached World geometry
call / instantiate     develop
higher order            generated authority selecting another detached stage
genericity              open Point incidence
generativity            fresh World graft + fresh Points
capture                 explicit authority transfer
hidden state             unspent authority in a private actual World
choice                   competing detached stages
join                     open branch identity at a shared future
concurrency              sibling actual Worlds
communication            transport Faces
continuation             scarce authority + detached resume stage
handler selection        Point incidence
recursion                fresh authority/state unfolding
existential package      hidden fresh Point carried by authority
separate compilation     canonical geometric frontier
frontier polymorphism    artefact-level Point-row specialisation
cross-carrier identity   Point gluing
cancellation             EPSILON
retirement               exit-time absence of resident unspent authority
```

The claim is not that every one of these features has been fully solved. The interesting fact is that hostile examples have generally made the kernel **smaller or stricter**, rather than forcing a new feature-specific semantic object.

## Repository

```text
src/                 executable reference model and public `worlds` surface
tests/               public API, directed hostile tests and generated stress tests
formal/README.md      formal-verification programme; no proof code yet
LAWS.md               compact semantic laws
RESEARCH.md           why this may matter
FUTURE.md             current programme and unresolved questions
CHANGELOG.md          release history
```

The Lua is an executable oracle, not a production implementation. It is intentionally direct and inspectable.

Run everything with:

```sh
make
```

Current `v0.1.0` checkpoint:

```text
118 directed semantic/adversarial tests
10,500 generated stress/differential cases
```


## 0.1 public surface

```lua
local Worlds = require('worlds')

Worlds.VERSION      -- "0.1.0"
Worlds.Model
Worlds.Certified
Worlds.Separate
Worlds.Frontier
Worlds.Completion
```

The supported portable formats are deliberately versioned independently of the package:

```text
worlds.certified/1
worlds.unit/1
worlds.frontier-artifact/1
```

`Frontier` belongs to the compiled-artefact layer, not the semantic carrier. A frontier variable is a variadic row of Point positions. `specialise` removes those variables and returns an ordinary closed `worlds.unit/1`; only then may `Separate.import_unit` install the geometry. Actual caller identity is still bound later by `develop`.

`federation.lua` and `choice_normalise.lua` remain research helpers in the repository but are not part of the 0.1 public `Worlds` table.

## A note on ambition

The kernel is small enough that it is tempting to make large claims. We should resist that temptation until the mathematics and comparisons with neighbouring work are stronger.

The working research question is narrower and, I think, more interesting:

> How much resource-sensitive, higher-order and modular computation can be explained by identity, authority, transformation, locality and detached possibility alone?

`RESEARCH.md` records the consequences we think are worth pursuing. `FUTURE.md` records the places most likely to break the model.
