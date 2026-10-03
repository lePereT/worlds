# Verification

The laboratory imports no Relay module.

## Stock bundled Worlds 0.6.4

`make full-check`: **PASS** including:

- core: 5,129 assertions;
- differential: 10,000 assertions;
- restricted differential: 5,000 cases;
- partial differential: 104,510 assertions;
- nested differential: 3,000 cases;
- branching differential: 3,000 cases;
- closure differential: 2,000 cases;
- advance differential: 2,000 cases / 440,334 assertions;
- historical algebra: 15 files.

Expanded hostile lab: **47/48 pass**.

The sole red is X44, Construction-image incidence.  This is a Worlds mechanics
finding, not a failing Theory pressure.  See `KERNEL_FINDING.md`.

## Refined mechanics candidate

Candidate differences from stock Worlds are confined to `_kernel.lua` join
materialisation/validation plus two native Construction regressions:

1. reject cyclic induced Membrane-parent quotients;
2. rematerialise affected frame Membranes/Points when their parent/placement
   incidence no longer agrees with the quotient image.

Results:

- hostile extended-Theory suite: **48/48 PASS**;
- X44: **3,222 generated quotient attempts** checked;
- generated exact Theory rebase: **2,154 lawful quotients** checked;
- Worlds `make full-check`: **PASS** including all differential suites.

The candidate intentionally rejects 30 ancestor/descendant quotient patterns
which stock 0.6.4 reports as successful but for which a coherent quotient parent
forest cannot be materialised.

## Other generated/stress counts

- support Match atlas: 3,969 directional comparisons;
- same-Geometry correlation atlas: 384 probes across 24 pairings;
- validate-before-hide generated conflicts: 16;
- four-corridor feedback permutations: 24;
- repeated fresh Theory materialisations: 64;
- long renewal stress: 1,024 commits.
