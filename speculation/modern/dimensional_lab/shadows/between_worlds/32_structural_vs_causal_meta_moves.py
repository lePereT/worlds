#!/usr/bin/env python3
"""The same exact Worlds support two qualitatively different higher relations.

Structural relation: arbitrary one-coordinate alternative rehosting (the jump
atlas).  It is reversible and loop-rich.

Causal/meta-rewrite: move one host one Membrane edge toward the causal support.
This directed system terminates, is locally confluent, and has the unique normal
form in which every Face is hosted at the causal support.

Thus the structural-vs-causal split found inside Worlds reappears in the space
between Worlds.
"""
from itertools import product
from collections import deque

TREE=[(0,1),(1,2),(2,3),(3,4),(1,5),(5,6),(0,7),(7,8)]
ADJ={i:set() for i in range(9)}
for a,b in TREE:ADJ[a].add(b);ADJ[b].add(a)
PROFILES={
 'R': (0,[{1,2,3,4,5,6},{7,8}],97,168,72,6),
 'A': (1,[{2,3,4},{5,6},{7,8}],356,876,711,8),
 'B': (2,[{3,4},{5,6},{7,8}],453,1152,972,9),
}

def valid(v,branches):return all(sum(x in b for x in v)<=1 for b in branches)
def parent_toward(base):
    d={base:0};par={base:None};q=deque([base])
    while q:
        x=q.popleft()
        for y in ADJ[x]:
            if y not in d:d[y]=d[x]+1;par[y]=x;q.append(y)
    return d,par

print('orient local rehosting toward the causal support')
for name,(base,branches,EV,EE,ED,EH) in PROFILES.items():
    V={v for v in product(range(9),repeat=3) if valid(v,branches)};dist,par=parent_toward(base)
    out={v:[] for v in V}
    for v in V:
        for i,x in enumerate(v):
            if x==base:continue
            w=list(v);w[i]=par[x];w=tuple(w)
            assert w in V,'normalising toward causal support must preserve lawfulness'
            assert sum(dist[z] for z in w)==sum(dist[z] for z in v)-1
            out[v].append(w)
    sinks=[v for v in V if not out[v]]
    assert sinks==[(base,base,base)]
    edges=sum(map(len,out.values()));diamonds=0
    for v,ws in out.items():
        for i in range(len(ws)):
            for j in range(i+1,len(ws)):
                assert set(out[ws[i]]) & set(out[ws[j]]),'independent one-step reductions must close a confluence diamond'
                diamonds+=1
    height=max(sum(dist[x] for x in v) for v in V)
    assert (len(V),edges,diamonds,height)==(EV,EE,ED,EH)
    print(' ',name,'Worlds',len(V),'directed normalisation edges',edges,'diamonds',diamonds,'max height',height,'unique sink',sinks[0])

print('PASS: meta-causal rehosting is terminating and locally confluent while structural alternative space remains loop-rich')
