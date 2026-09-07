# Worlds test strategy

**Status: maintained test architecture and executable-evidence guide.**

Worlds tests are organised by semantic law rather than development history. The
semantic laws themselves live in `../docs/LAWS.md`; tests are executable evidence
for those laws, not a second prose specification.

## Gate structure

The normal gate is:

```text
tests/geometry/
tests/cut/
tests/algebra/
tests/authority/
tests/state/
tests/concurrency/
tests/theory/
```

Additional independent pressure comes from:

- `reference/cut_differential.lua` — brute-force Cut oracle;
- `torture/inherited.lua` — inherited generated cases;
- `torture/whole_model.lua` — history/boundary and composition torture;
- `shape/structural.lua` — work/shape assertions;
- `../external/geometric_products/` — independent product/resource client;
- `../external/relay_source/` — independent Relay-source client.

Obsolete representation tests are not preserved merely for compatibility. When
an implementation mechanism disappears, tests should move to the law it had been
trying to establish. For example, the operational model has no membrane tree, so
current tests assert exact frame preservation rather than tree-node sharing.

Hostile presentation tests deliberately permute non-semantic order, including
ordinary and joint Face incidence. Relay transport likewise normalises unordered
Face incidence before content hashing.

## Structural work assertions

`shape/structural.lua` is part of `make check`. It contains no timing threshold.
It currently asserts:

- homogeneous `n × n` scarcity finds a first witness in exactly `n` candidate
  checks and stores no demand×offer matrix;
- a fixed work budget advances by exactly that many candidate checks;
- 200 exact historical transitions produce 200 Faces while operational state
  remains one live Strand;
- updating one Strand amongst 10,000 unrelated sibling authorities preserves the
  other 9,999 exact occurrences;
- a 1,000-part/999-cut assembly materialises to exactly 1,000 Faces, one ingress
  and one egress;
- a 64-Face mutual-support ring normalises to one joint Face.

The benchmark target is the **shape of semantic work**, not the speed of a
particular Lua runtime or machine. Wall-clock probes may be useful during
implementation work, but they are not correctness or release gates.

Garbage-collection regressions similarly test eventual reachability after transient execution frames have ended. They must not depend on an exact number of collection cycles: LuaJIT and the fallback Lua runtimes differ in weak-table and VM-stack collection cadence.

## Documentation discipline

`docs.lua` is part of the normal gate. It maintains an exact whitelist of
Markdown files in the release tree, rejects stray top-level design documents,
and checks the declared authority/status of maintained documents. Adding a new
Markdown file therefore requires an explicit test change rather than allowing a
note to acquire accidental authority.
### Runtime-independent generated cases

Seeded/generated tests use `tests/prng.lua`, not the host runtime's `math.random`. LuaJIT and compatibility Lua runtimes must therefore exercise the same generated cases and report the same assertion counts.

