# Performance constitution

**Status: maintained performance constitution.**

The intended complexity parameter is:

```text
relevant live boundary
+ incoming open process
+ genuine semantic ambiguity
```

not accumulated history or unrelated programme size.

The reference implementation therefore deliberately avoids:

- demand×offer candidate matrices;
- operational causal-history retention;
- membrane-based authority discovery;
- ambient Point enumeration;
- global epochs and invalidation counters;
- mandatory canonicalisation in the hot path.

Optimisations should first ask whether the kernel is posing the correct geometric
question.  Persistent caches or specialised indexes should be justified by
measurement, not installed as a parallel semantic model.

Wall-clock probes may be useful during development, but they are not correctness
or release gates.  `../tests/README.md` records the asserted work shapes and test architecture.
## Search stack discipline

Retained Cut search may be as deep as the number of demanded scarce Strands. Production search must therefore keep semantic backtracking depth in explicit heap/query state rather than recursive Lua call frames. A valid deep first witness must not depend on the host VM's call-stack limit.

The structural shape gate includes a 10,000-demand first-hit case specifically to guard this property.

