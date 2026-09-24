# Worlds 0.6.3 — exact construction transport and presented boundaries

Worlds is a small operational geometry in which exact identity, scarce authority,
causal transformation and locality arise from incidence and open boundary.

Worlds 0.6.3 is an additive edge release.  The verified Geometry centre is
unchanged.  No carrier kind, causal law, `boundary`, `join`, `advance`, Question
or matching rule changes.

The release adds two deliberately small public edge modules:

```lua
local Construction = require('worlds.construction')
local Presentation = require('worlds.presentation')
```

`Construction` makes the existing exact image returned by `join` into an
immutable witness that can safely be passed between components.  `Presentation`
is an ordered, non-authoritative view of selected exact open Strand occurrences
relative to one ambient Geometry.  It gives clients somewhere to put boundary
presentation structure without thickening that structure into causal Geometry.

The main API remains unchanged:

```lua
local W = require('worlds')
```

## Verified centre

The operational ontology remains:

```text
Membrane
Point
Strand
Face
Geometry

boundary
join
advance
```

`join(parts,equations)` remains the sole Geometry-changing primitive.  The first
part remains the frame; exact unaffected frame carriers survive literally;
later-part carriers materialise as required; and causal SCCs normalise to one
joint Face exactly as before.

The release does **not** add W1/W2/W3 types, rank, higher cells, cuts, a new
composition algorithm or a second execution semantics.

## Construction

```lua
local Construction = require('worlds.construction')

local c = Construction.join(parts, equations)
local result = c:result()
local mapped = c:image(source_carrier)
```

`Construction.join(P,E)` performs the ordinary `W.join(P,E)` operation and
retains immutable access to:

```text
ordered parts
normalised equations
result Geometry
exact construction-relative carrier image
```

Construction carries no programme authority.  It is a witness of one exact
materialisation, not another way to compose Geometry.

The image is important because exact identity after construction depends on the
actual materialisation path.  It also records the kernel's existing many-to-one
Face image under causal SCC contraction and the disappearance of cyclic Strand
authority.

## Presentation

```lua
local Presentation = require('worlds.presentation')

local p = Presentation.new(body, {
  {arg1, arg2},
  {result},
})
```

A Presentation is a finite ordered family of rows of selected exact **open
Strand occurrences** relative to one exact ambient Geometry.

It is not Geometry.  It owns no carrier, grants no authority and imposes no
causal order.  Rows, coordinate order and multiplicity are presentation
semantics only.  Any number of different Presentations may describe the same
Geometry.

Coordinates may be omitted, repeated and arranged in empty rows.  This permits a
client to expose public ports while leaving hidden authority ordinary Geometry.
An empty row has no completion meaning.

### Residual transport

```lua
local p2 = p:transport(c)
```

The Presentation ambient must be one of `c:parts()` by exact Geometry identity.
Each coordinate is mapped pointwise through `c:image`.  Mapped Strands are
retained, in the same row order and with the same multiplicity, exactly when they
remain open in `c:result()`.  Coordinates which become internal or are
annihilated disappear.

Transport therefore supports residual public presentations without causal
wrappers.  It never creates completion or any other authority.

Presentation is intentionally an in-memory relative view.  If an enclosing
format such as Relay needs durable presentations, that format must encode enough
ambient-relative exact coordinates to reconstruct the Presentation after import.

## Why 0.6.3 stops here

The non-authoritative research programme has become substantially richer since
0.6.2.  It now includes exact incidence reductions, intrinsic rank-1-like
structures, higher coherence examples, fixed-shadow realisation fibres,
Membrane/causal-spine topology and coherent correspondences between exact-distinct
construction outcomes.

Those experiments are preserved under `speculation/modern/dimensional_lab/`,
including `shadows/`, `fibre_census/` and `between_worlds/`.

They strongly motivate separating presentation, causal Geometry and exact
construction transport, but they do **not** yet justify production W1/W3 types,
a ranked-complex API, a canonical inter-World deformation relation or a higher
cell carrier.  0.6.3 therefore promotes only what repeated experiments already
require while leaving the dimensional interpretation free to evolve.

## Questions and live computation

The finite judgement API remains in `worlds.query`:

```text
Match(A,B;S,T,D,R,C,E0)
Close(P;S,T,D,R,C,E0)
```

`W.solve(A,B,seeds)` remains the complete Match convenience.  `advance` remains
definitionally:

```text
boundary(join({boundary(world), development}, equations))
```

Optional `worlds.history` observes execution only and is never consulted by the
kernel.

## Checks

```sh
make full-check
make speculation-check
```

`full-check` includes maintained Construction and Presentation tests in addition
to the unchanged Geometry, Question, differential and historical suites.
`speculation-check` runs the non-authoritative research corpus separately.

See `docs/LAWS.md` for normative semantics and `CHECKS.md` for the captured
release acceptance record.
