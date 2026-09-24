#!/usr/bin/env python3
"""Coordinate-permutation isotropy in the support realisation fibre.

Exact Faces are labelled coordinates in the marked fibre.  If that exact
identity is forgotten, S_k acts by permuting coordinates.  The action is not
free: reusable causal-spine sites admit repeated hosts and therefore fixed
points.  Causal descent grows these isotropy strata.
"""
from itertools import product,permutations
from collections import Counter

PROFILES={
 'R': [{1,2,3,4,5,6},{7,8}],
 'A': [{2,3,4},{5,6},{7,8}],
 'B': [{3,4},{5,6},{7,8}],
}
P=list(permutations(range(3)))

def valid(v,branches):return all(sum(x in b for x in v)<=1 for b in branches)
def act(v,p):return tuple(v[p[i]] for i in range(3))

expected={
 'R': (97,21,{1:72,2:24,6:1}),
 'A': (356,69,{1:306,2:48,6:2}),
 'B': (453,90,{1:378,2:72,6:3}),
}
print('quotient the marked support fibre by forgetting exact Face labels')
for name,branches in PROFILES.items():
    V={v for v in product(range(9),repeat=3) if valid(v,branches)}
    seen=set();orbits=[]
    for v in V:
        if v in seen:continue
        orb={act(v,p) for p in P};seen|=orb;orbits.append(orb)
    stabilizers=Counter(sum(act(v,p)==v for p in P) for v in V)
    ev,eo,es=expected[name]
    assert len(V)==ev and len(orbits)==eo and dict(stabilizers)==es,(name,len(V),len(orbits),stabilizers)
    print(' ',name,'marked Worlds',len(V),'unlabelled orbits',len(orbits),
          'vertex stabilizers',dict(sorted(stabilizers.items())),
          'orbit sizes',dict(sorted(Counter(map(len,orbits)).items())))

print('PASS: forgetting exact identity creates non-free symmetry strata controlled by causal-spine reuse')
