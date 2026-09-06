# Worlds 0.4.0

Worlds is a small algebraic substrate for exact, resource-sensitive computation.

Its kernel is deliberately narrow:

```text
immutable nested geometry
+
contextual selection
+
exact attachment
+
fresh gluing
```

The kernel knows only geometry. It has no built-in concept of value, function,
module, process, transaction, continuation, ownership type, scheduler, state
machine or concurrency primitive. Those are interpretations and derived
constructions over the geometry, usually with the help of a domain Theory.

Worlds began as part of the semantic work behind Relay, but is independently
versioned and intended to stand on its own. Relay is a demanding client of
Worlds rather than its containing project.

## Geometry

A `Geometry` is an immutable finite directed 2-complex inside a forest of
membranes.

```text
membrane          locality / nesting
Point       0-cell exact semantic identity or witness
Strand      1-cell one authority occurrence
Face        2-cell one causal occurrence
```

Every cell belongs to one membrane. Strand incidence on Points and Face
incidence on Strands are ordered. Producer-to-consumer Face incidence is
acyclic.

This exact geometry is intentionally intensional. It records which occurrence
is which even when a higher Theory later regards several exact structures as
observationally equivalent.

## Patterns and exact attachment

A Geometry may also be used as a pattern. Points in pattern membranes mapped to
existing source membranes act as variables under attachment substitution:

```text
one repeated pattern Point
    must map consistently to one source Point

two distinct pattern Points
    may map to the same or different source Points
```

Point substitution is therefore functional but not injective. Strand matching
remains injective because Strands are scarce authority occurrences.

For source Geometry `G`, a selected set of membranes `S`, and pattern Geometry
`P`:

```text
Att_S(G,P)
```

is the family of complete exact attachments preserving sorts, membrane topology
and ordered incidence while using each exposed terminal Strand at most once.

Selection is contextual input to the question. It is not state stored in the
Geometry.

## Fresh gluing and computation

An exact attachment `μ` is evidence that the pattern can be glued into the
selected source context:

```text
G' = G ⊕μ P
```

Mapped cells are identified exactly as witnessed by `μ`. Pattern cells not
identified by the attachment are fresh in `G'`.

`G` is never mutated. A computation may therefore be understood as repeated
exact attachment and fresh gluing:

```text
G --μ1--> G1 --μ2--> G2 --μ3--> ...
```

Provisional developments need no rollback object: an unwanted derived Geometry
can simply be discarded. Irreversible external effects remain a concern of the
system using Worlds; immutable semantic development does not pretend to undo
physical reality.

## Identity, authority and causality

Worlds keeps several distinctions separate:

```text
Point identity       what exact semantic entity/witness is involved
Strand occurrence    one scarce occurrence of authority
Face incidence       what causally consumes and produces authority
membrane locality    where the geometry is situated
```

This separation is what allows higher systems to derive ownership-like,
continuation-like and process-like behaviour without putting those notions into
the kernel.

Two exact Points remain different even if a Theory says they both denote the
integer `42`. Conversely, several pattern Point variables may substitute to the
same exact Point without duplicating scarce Strand authority.

## Theory

Worlds is theory-blind. A Theory may add domain meaning while leaving exact
Worlds identity intact.

A Theory may, for example:

- interpret Points as numbers, names, terms, proofs or domain states;
- accept, reject or leave unknown a structurally valid attachment;
- define a coarser observational equality over Points or complete geometries;
- reason symbolically where literal geometric expansion would be impractical;
- derive composition over Theory-equivalent representatives when exact
  representative attachment is insufficient.

The last case matters for process-like theories. If structural congruence makes
two complete geometries equivalent, one representative may expose an exact
attachment that another does not. A sound higher Theory may therefore derive a
quotient-sensitive relation such as `Att^T` rather than merely post-filtering
`Att` on one representative.

Theory equality never changes the exact Point/Strand identity recorded by
Worlds and never by itself merges scarce authority.

## Derived structure

The small kernel already supports a broad range of derived readings without
adding carrier kinds.

For example:

- state may be represented by the currently available authority geometry;
- conflict may arise from competing use of scarce Strands;
- causality may arise when later attachment requires authority produced by an
  earlier Face;
- independent developments may be recognised by commuting gluing diagrams;
- generic or nominal identity can be expressed through Point substitution and
  exact identity;
- open-process products can be assembled geometrically, with domain Theory
  supplying only the additional extensional laws that exact geometry cannot
  honestly know.

These are consequences and constructions over Worlds, not extra kernel
entities. `LAWS.md` states the kernel contract. `RESEARCH.md` records the
remaining questions about derived theories, products, performance and broader
systems use.

## Lua API

The public module is intentionally small:

```lua
local Worlds = require('worlds')
local G = Worlds.Geometry
local A = Worlds.Attach
```

A Geometry is built immutably through a builder:

```lua
local b = G.builder()
local m = b:membrane(nil, 'place')
local p = b:point(m, 'Value')
local s = b:strand(m, 'Owned', {p})
local geometry = b:finish()
```

Attachment and gluing are explicit:

```lua
local attachments = A.all(source, {selected_membrane}, pattern)
local attachment = A.one(source, {selected_membrane}, pattern)
local next_geometry, image = A.glue(attachment)
```

Exact geometric equality up to fresh-name renaming is available as:

```lua
Worlds.same(a, b)
```

## Development

Worlds is developed with a deliberately small Lua-shaped toolchain. The
repository includes an Alpine devcontainer with a pinned upstream LuaJIT 2.1
build, Lua 5.4 as the ordinary-Lua fallback, and a small `zsh` environment.

The Makefile prefers interpreters in this order:

```text
luajit -> lua -> lua5.4 -> lua5.3 -> texlua
```

Override the selection explicitly when useful:

```sh
make LUA=texlua test
```

Useful commands:

```text
make doctor     show the selected interpreter and local setup
make check      run syntax and project checks
make test       run the complete semantic suite
make torture    run the focused higher-Theory stress cases
make bench      run benchmarks when present
make tree       show the repository file tree
```
