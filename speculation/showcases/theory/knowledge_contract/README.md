# Relay knowledge-domain algebra contract lab

This directory is an executable falsification lab for the question: what exact algebraic contract
must a Relay knowledge domain satisfy?

The candidate contract is in `CONTRACT.md`; experimental conclusions are in `RESULTS.md`.

The showcase deliberately uses several models rather than one implementation:

- finite relational semantics for the fibre/reindex/existential laws;
- actual Worlds Construction for annihilation and quotient pressures;
- a corelation-like model retaining hidden Construction identity classes;
- generated positive fixed-point systems for cross-domain closure;
- certified observation pressures;
- an exact-versus-abstract comparison; and

Run from the Worlds root with `LUA=lua ./speculation/showcases/theory/knowledge_contract/run.sh`.

This packaged showcase contains the self-contained algebraic and Construction pressures. Historical
Relay-domain migration evidence is documented in `RESULTS.md` but its frozen Relay fixture is not
shipped as part of the Worlds speculation runner.

## Mathematical references used to frame the result

- Fong and Spivak, *Regular and relational categories: Revisiting Cartesian bicategories I*,
  arXiv:1909.00069.
- Fong and Spivak, *Graphical Regular Logic*, arXiv:1812.05765.
- Coya and Fong, *Corelations are the prop for extraspecial commutative Frobenius monoids*,
  arXiv:1601.02307.
- Cousot, Cousot and Mauborgne, *The reduced product of abstract domains and the combination of
  decision procedures*, FoSSaCS 2011.

These references identify established mathematics close to the observed laws. The Relay contract
itself is the result of the executable pressures in this directory, not a verbatim adoption of any
one framework.
