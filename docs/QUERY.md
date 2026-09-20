# Finite Questions

**Status: normative definition of the finite judgement layer.**

A Question is outside the Worlds operational ontology. It carries no authority,
is not transported programme meaning and does not change Geometry. It describes
one exact finite judgement whose constructive witnesses may be handed directly
to strict `join`.

Worlds exposes two precise Question forms.

## Directional matching

```text
Match(A,B; S,T,D,R,C,E0)
```

with:

```text
A   source/world Geometry
B   target/development Geometry
S   selected exact egress(A)
T   selected exact ingress(B)
D   sources which must occur in domain(E)
R   targets which must occur in codomain(E)
C   optional admissibility relation C subset S x T
E0  seeded exact equations
```

`D` defaults to the empty set. `R` defaults to `T`. `C` defaults to `S x T`.
`S`, `T`, `D`, `R`, `C` and `E0` are sets/relations; presentation order is not
semantic.

A solution `E` must satisfy the directional Worlds matching judgement as well as:

```text
E0 subset E
E subset C
D subset domain(E) subset S
R subset codomain(E) subset T
```

The matching judgement incorporates exact scarcity, target uniqueness, Strand
arity and ordered Point incidence, rigid imported Point identity, target-local
Point/Membrane substitution, locality equality/ancestry and the causal-development
condition on `B`.

Matching is intentionally stronger than direct quotient construction. A Geometry
fragment may be lawfully joined while still being unsuitable as a rooted target
development pattern.

## Direct finite closure

```text
Close(P; S,T,D,R,C,E0)
```

where `P` is an ordered finite set of pairwise-disjoint Geometry parts and:

```text
S   selected exact open egress occurrences drawn from P
T   selected exact open ingress occurrences drawn from P
D   sources which must occur in domain(E)
R   targets which must occur in codomain(E)
C   optional admissibility relation C subset S x T
E0  seeded exact equations
```

Again `D` defaults to empty, `R` defaults to `T`, and `C` defaults to `S x T`.
The ordering of `P` is exact because it is the ordering subsequently supplied to
`join`; the finite sections/relations themselves remain mathematical sets.

`E` is a solution exactly when:

```text
E0 subset E
E subset C
D subset domain(E) subset S
R subset codomain(E) subset T
join(P,E) is lawful Worlds Geometry
```

This is the judgement used for direct multi-part, bidirectional and same-Geometry
closure. It is **not** implemented by first creating a disjoint product and then
asking a same-Geometry matching question; establishing the product first can
change locality and therefore change the judgement.

`Close` does not impose the directional target-development premise of `Match`.
That distinction is deliberate.

## One evidence algebra

Both forms return:

```text
yes(E)   constructive exact solution
no(C)    exhaustive absence for this exact finite Question
more     incomplete calculation
done     enumeration exhausted after one or more yes results
```

Every public `yes(E)` has one hard guarantee:

> strict `join(question:parts(), E)` succeeds and returns lawful Geometry.

For a Match Question, `parts()` is `{boundary(A),B}`, except same-Geometry Match
uses `{B}`. For a Close Question it is exactly `P`.

`no` carries an immutable `Refutation` tied to the exact Question. `more` is
never semantic refutation.

## API

```lua
local Q = require('worlds.query')

local match = Q.match(world, development, {
  sources = selected_egress,
  targets = selected_ingress,
  required_sources = must_be_consumed, -- optional; default {}
  required_targets = must_be_closed,   -- optional; default targets
  admissible = exact_pairs,            -- optional; default S x T
  seeds = exact_seed_equations,        -- optional
})

local close = Q.close({part_a, part_b, part_c}, {
  sources = selected_open_egress,
  targets = selected_open_ingress,
  required_sources = must_be_consumed,
  required_targets = must_be_closed,
  admissible = exact_pairs,
  seeds = exact_seed_equations,
})

local search = Q.solve(close)
```

The older vague `Question.new` constructor does not exist. The judgement form is
explicit at its construction site.

The ordinary convenience:

```lua
W.solve(A,B,seeds)
```

is the complete Match Question with all source egress selected, all target ingress
selected and required, complete admissibility, no required sources and the supplied
seeds.

## Search machinery

`worlds.query_engine` is replaceable acceleration for Match. It uses counted
source sections, endpoint-thread quotienting, factor elimination, Hall feasibility
and exact allocation.

`worlds.query_relation` is the shared Geometry-free finite relation solver. Given
finite target-to-source support, it enumerates injective relations covering required
targets and required sources. Required range is allocated first, any still-uncovered
required domain is allocated symmetrically against optional targets, and only then
are genuinely optional edges enumerated. Hall feasibility rejects deficient support
before exact injection search. `worlds.query_closure_engine` therefore only compiles
Close admissibility into support, removes exact seeds and reconstructs equations.

Close deliberately does **not** prune on unlawful partial quotients: later equations
may carry a locality needed by the final composite, so that pruning would be
unsound. Structural support beyond the finite admissibility relation must likewise
be monotone before it may be used as a search filter.

The public Question wrapper validates every prospective witness against the
kernel's strict join law before exposing `yes(E)`. Search engines may be replaced
without changing either `Solutions(Match(...))` or `Solutions(Close(...))`.
