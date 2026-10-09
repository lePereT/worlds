# Candidate algebraic contract for Relay knowledge domains

Status: research candidate. This is deliberately stronger than the current Relay Theory API. It
states the semantic laws a knowledge domain should denote; it does not prescribe one data
structure, solver, or syntax.

## 1. Summary

The smallest contract supported by the current experiments is not a fact database or a theorem
prover. It is a bottomed regular knowledge doctrine over exact Worlds occurrence contexts, with a
generic action of Worlds Construction correspondences, positive reduced-product interaction
between domains, and certified authority-free observation.

In plainer terms: knowledge is positive constraint, exact identity belongs to Worlds, hiding is
existential elimination, domain interaction is monotone closure, and observation must publish a
positive certificate that can be replayed.


## 1.1 Executable host boundary

The executable lab mirrors this semantic contract with an intentionally smaller implementation
contract. A domain object is accepted only if it supplies four effective operations:

- `equal(C, a, b)`;
- `meet(C, a, b)`;
- `reindex(C, a, D, f)`; and
- `exists(C, a, D)`.

Top is absence of a domain component; bottom and Deferred are host-level outcomes. Entailment and
Hit/Retry/Unknown are derived from meet and equality. Construction transport is generic host code
over native Worlds correspondence. Observation and portable codecs are optional consumers outside
this domain contract.

## 2. Occurrence-indexed knowledge fibres

For each finite exact occurrence context C and each knowledge domain D, there is a semantic fibre
K_D(C). Its elements are extensional knowledge states over the exact occurrences in C.

Each fibre has top, bottom, and finite meet.

- top means no positive constraint;
- bottom means contradiction / no possible extensional state;
- meet means simultaneous positive knowledge.

Define the information/entailment order by a <= b exactly when a meet b = a. Thus a is at least as
informative as b. Stronger knowledge is lower in this order.

Required laws are associativity, commutativity and idempotence of meet; top is its identity; bottom
is absorbing. Valid Relay State knowledge is non-bottom.

The public logical interface does not require disjunction, implication, universal quantification or
logical negation. A domain may of course have an atomic relation such as disequality; that does not
add meta-logical negation to the doctrine.

## 3. Judgement is derived from the order

Given valid current knowledge k and a positive requirement r in the same fibre:

- Hit exactly when k <= r;
- Retry exactly when k meet r = bottom;
- Unknown otherwise: r is consistent with k but would be a strict positive refinement.

No domain-specific entailment protocol is semantically primitive. A solver may implement these
questions however it likes, but the answers must agree with this order.

## 4. Exact reindexing

Exact renaming/substitution of occurrence variables induces contravariant reindexing. For an exact
map f, write f* for the induced map on knowledge.

Reindexing must preserve top, bottom and finite meet, and must satisfy identity and composition.
Knowledge is therefore equivariant under exact alpha-renaming/isomorphism. Pointer identity,
allocation order and debug labels cannot affect semantic knowledge.

Exact carrier equality itself is owned by Worlds, not redefined by each knowledge domain.

## 5. Existential hiding

When exact occurrences cease to be public, knowledge is not filtered fact-by-fact. It is
existentially projected.

For a projection p, existential hiding exists_p is left adjoint to reindexing p*. In the entailment
order this means: exists_p(a) <= b exactly when a <= p*(b).

The required coherence laws are:

- identity and composition of hiding;
- monotonicity and preservation of bottom;
- Frobenius reciprocity: public knowledge may be pulled through an existential elimination;
- Beck-Chevalley stability: exact substitution and hiding commute around the corresponding exact
  pullback square.

Existential hiding is not required to preserve meet. In fact it generally cannot. Knowledge which
shares a hidden witness must be combined before that witness is eliminated, because the hidden
witness may leave a public correlation.

## 6. Worlds Construction transport

A Worlds Construction does more than provide a partial final image. It can identify exact source
occurrences and later annihilate the resulting class. Those intermediate identifications can leave
public knowledge after the carrier itself disappears.

Therefore semantic knowledge transport must be indexed by the exact Construction correspondence,
not only by `Construction:image`.

The required Construction witness is equivalent, for knowledge purposes, to an exact partition of
source and result occurrences: source occurrences may share an exact construction-relative class;
a class may be connected to one surviving result occurrence or may be hidden entirely. This has
the shape of a restricted corelation.

Generic Theory transport, rather than a domain callback, should then:

1. impose the Construction's exact identifications on source knowledge;
2. detect any contradiction exposed by those identifications;
3. existentially eliminate construction classes with no public result carrier;
4. rename surviving classes to the exact result carriers; and
5. apply the target domain's canonical positive closure.

This action must be monotone, bottom-preserving, equivariant under exact isomorphism, and functorial:
identity Construction acts as identity, and staged transport equals transport through the composed
Construction correspondence.

Transport is not generally a meet homomorphism, because existential elimination is not.

### Worlds 0.6.6 discharges this pressure

Worlds 0.6.6 now exposes the required immutable `Construction:correspondence()` evidence directly.
It supplies opaque source/result quotient classes, retains source-only classes after annihilation,
and composes across staged Constructions including fresh source parts. Knowledge transport therefore
uses this native evidence and never reconstructs quotient identity from `Construction:image`, raw
equations, or a Theory-local union-find. Exact identity remains sovereign in Worlds and the evidence
grants no authority.

## 7. Finite support and no invented exact identity

A knowledge element has finite support in the exact occurrences of its context plus ordinary
extensional literals. A knowledge domain cannot mint a Membrane, Point, Strand or Face, and cannot
invent equality between exact carriers.

Domain-private existential witnesses are allowed only as alpha-invariant logical witnesses; they
must never become exact Worlds identity or authority.

## 8. Cross-domain interaction

Independent domains combine by product. Genuine interactions between domains are positive
reductions on that product.

A reduction must be monotone, idempotent, semantics-preserving, and information-increasing: in the
entailment order, rho(k) <= k. It may expose consequences to another domain, but may not retract a
consequence when more positive knowledge is added.

Interacting positive reductions may be iterated to their least common fixed point. Any fair
schedule must reach the same semantic result. Reasoning from absence is therefore excluded from
semantic Theory: absence of evidence is not positive evidence.

At the semantic quotient, reduction does not add new meaning; it computes a more explicit/canonical
representative of meaning already implied by the combined domains.

## 9. Observation

Observation is authority-free query of knowledge, not a second semantic channel.

A determinate observation of value v must return a positive certificate r in the same knowledge
fibre such that current knowledge k entails r, and r is sufficient to force v for that observation.
The certificate is what dependent transactional formation records as a requirement of the
resulting composite Rule.

Consequently a successful observation is stable under every consistent strengthening of knowledge.
If several observational values remain possible, an implementation must not choose one arbitrary
witness. The semantic result is Unknown (or an explicit positive alternative structure outside the
knowledge fibre).

Observation must not expose a Strand or other exact authority as an ordinary value. Exact carrier
identity is likewise not a public value unless a separate extensional domain explicitly publishes
an authority-free name for it.

## 10. Exact semantics versus solver implementation

The semantic fibre is exact. A cheaper implementation may use an abstract or incomplete internal
solver, but solver incompleteness is not semantic Unknown.

A production operation must either return the exact semantic result or report a separate
computational status such as Deferred / resource exhausted. It must never turn inability to prove a
true consequence into Retry, nor make programme meaning depend on solver precision or fuel.

This separates two notions which current Theory tends to conflate:

- semantic Unknown: a requirement is genuinely consistent but not entailed;
- computational Deferred: the chosen procedure did not determine the exact semantic answer.

## 11. Effectivity requirements

The laws above constrain denotation. A Relay implementation also needs an effectiveness contract.
For finite input, every domain must provide deterministic, side-effect-free procedures for its
chosen exact representation, or explicitly return Deferred at the evaluator boundary.

Canonicalisation/reduction must be idempotent and invariant under evaluation order. Semantic answers
may not depend on wall clock, random choice, object address, table iteration order, debug names or
other host artefacts.

A domain may use sophisticated algorithms internally, but an unrestricted theorem callback is not
itself a semantic licence. The implementation still has to satisfy the algebraic laws and its
termination/decision profile must be explicit.

## 12. What is deliberately not in the contract

The core contract contains no schemas, Theory variables, unification engine, Horn-clause language,
generic query engine, preference, authority, causality, Presentation order, compiler provenance,
target cost or runtime policy.

Variables and pattern matching may be useful in the observation/query surface, but they are not
needed in the semantic algebra itself.

Preference remains OrderedFamily. Authority remains Strand. Causality remains Face/Construction.
Exact identity remains Worlds.

## 13. Incompatibilities found in current Relay

This contract is not merely a renaming of current Theory.

The current Integer domain does not derive all consequences of its ordinary order relations; for
example, two retained `ge` relations do not currently establish the corresponding transitive `ge`.
If `ge` is intended to denote ordinary integer >=, an exact semantic domain must preserve that
consequence.

More sharply, current Memory derives transitive reachability while the intermediate coherence node
is present. Its projector can then hide that node and drop both successor edges. A later query of the
public transitive reachability returns Retry. Under exact existential semantics, the hidden witness
must leave the public reachability consequence. Treating forgotten evidence as refutation violates
monotonicity.

The old `admit` versus `observe` distinction is also not primitive here. If a family, sequence or
other declaration is semantic meaning, it must enter as positive knowledge. A requirement does not
silently create semantic facts merely because they would be admissible.

These are real migration pressures, not implementation details.

## 14. Mathematical identification

The fibre/reindex/existential laws are essentially those of regular logic / a regular doctrine,
with an explicit contradiction element. Regular logic is the positive fragment generated by truth,
conjunction, equality and existential quantification; Worlds already supplies exact equality, so a
Relay knowledge domain does not need to reinvent it.

The Construction correspondence is corelation-like: it remembers equivalence classes across an
interface, including source-only classes that disappear. The domain-product closure resembles
reduced-product reduction from abstract interpretation, but Relay uses it to compute exact semantic
knowledge rather than to define an approximation.

This mathematical identification is guidance, not a requirement to expose category-theoretic APIs
in Relay.

## 15. Short constitutional form

A Relay knowledge domain may know more, never own more.

Its knowledge is positive, occurrence-relative, monotone and exact. It composes by conjunction,
travels only through exact Worlds correspondence, forgets by existential elimination, interacts
with other domains by positive fixed-point reduction, and publishes values only with replayable
positive certificates.

If a proposed domain operation needs negation-by-absence, arbitrary witness choice, invented exact
identity, authority use, causal action, non-monotone retraction, or solver-dependent semantics, it
does not satisfy this contract.
