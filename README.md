# Worlds 0.5.0

This is a clean reimplementation of the Worlds 0.5 whole model from
its laws and tests.  The research-7 implementation is retained as an independent
oracle/archaeological checkpoint; this tree does not preserve its internal
module layout or representation-specific tests.

## Model

Worlds is nested open causal geometry.

The only semantic carriers are:

- **Membrane** — structural locality;
- **Point** — exact identity;
- **Strand** — scarce authority carrying ordered Point incidence;
- **Face** — causal transformation consuming and producing finite unordered sets of Strand occurrences.

An open Geometry is a process.  Its ingress and egress are derived from
incidence.  Processes are juxtaposed by tensor and composed by exact scarce
boundary **Cut**.  Simultaneous cut-induced causal support cycles normalise to
one joint Face at the least common enclosing membrane.

Actual development additionally requires causal authority: identity and
structural compatibility alone never authorise modification of existing
locality.

Current operational state is the exact open egress boundary of completed
history.  `Operational` is therefore a specialised projection of the algebra,
not a second semantic model.

## Public API

```lua
local Worlds = require('worlds')

Worlds.Geometry
Worlds.Cut
Worlds.Algebra
Worlds.Operational
```

`Geometry`, `Cut` and `Algebra` are the semantic core. `Operational` implements
boundary execution without retaining closed causal history.

There are deliberately no semantic sorts, numeric IDs, Selection/View objects,
ambient Point search, membrane authority, transaction snapshots, global epochs,
or historical runtime state.

## Documentation

The maintained semantic documents live under `docs/`. Start with
`docs/README.md` for their authority/status map. Test strategy lives beside the
tests in `tests/README.md`; historical implementation notes live under
`archaeology/`. The release gate enforces the exact Markdown set so stray design
notes cannot acquire accidental authority.

## Check

The ordinary entry points both run the complete release gate:

```sh
make
make test
```

The Makefile selects the first available interpreter in this order:

```text
luajit -> lua -> lua5.4 -> lua5.3 -> texlua
```

Override it explicitly when needed, for example:

```sh
make LUA=texlua test
make doctor
```

The normal gate contains no timing threshold. It checks documentation/tooling
discipline, exact semantic laws, independent differential cases, generated
torture, external clients, and structural work/shape invariants.

LuaJIT is the intended bootstrap implementation. Ordinary Lua and TexLua are
portable fallbacks, not the performance reference.
