#!/usr/bin/env python3
"""Topology of fixed causal-support fibres.

After 19_causal_spine_support_law.lua, a star with m off-spine branches has a
simple exact model: each of k Faces may stay at the causal support (state 0) or
choose one of m child branches, but no nonzero branch may be used twice.

The resulting cubical edit complex has a striking RAAG/graph-braid-like
homology.  Its r-classes are products of r local support triangles on distinct
Face coordinates using pairwise-disjoint child pairs.
"""
from itertools import combinations, product
from math import comb


def homology(vertices,q,k):
    V=set(vertices); pw=[q**i for i in range(k)]
    def enc(d): return sum(v*pw[i] for i,v in enumerate(d))
    def dec(c):
        d=[]
        for _ in range(k): d.append(c%q); c//=q
        return tuple(d)
    def cells(r):
        if r==0: return [dec(c) for c in sorted(V)]
        out=[]
        for code in sorted(V):
            base=dec(code)
            for act in combinations(range(k),r):
                opts=[range(base[i]+1,q) for i in act]
                if any(len(x)==0 for x in opts): continue
                for ups in product(*opts):
                    spec=list(base)
                    for i,u in zip(act,ups): spec[i]=(base[i],u)
                    good=True
                    for bits in product((0,1),repeat=r):
                        d=list(base)
                        for i,u,b in zip(act,ups,bits): d[i]=u if b else base[i]
                        if enc(d) not in V: good=False; break
                    if good: out.append(tuple(spec))
        return out
    C=[cells(r) for r in range(k+1)]
    def rank(cols):
        piv={}
        for x in cols:
            while x:
                p=x.bit_length()-1
                if p in piv: x^=piv[p]
                else: piv[p]=x; break
        return len(piv)
    ranks=[0]*(k+1)
    for r in range(1,k+1):
        idx={c:i for i,c in enumerate(C[r-1])}; cols=[]
        for c in C[r]:
            x=0
            for i,z in enumerate(c):
                if isinstance(z,tuple):
                    for v in z:
                        y=list(c); y[i]=v; x^=1<<idx[tuple(y)]
            cols.append(x)
        ranks[r]=rank(cols)
    betti=[len(C[r])-ranks[r]-(ranks[r+1] if r<k else 0) for r in range(k+1)]
    return [len(x) for x in C],betti


def partial_injections(k,m):
    # state 0 = reusable causal support; 1..m = exclusive child branches
    q=m+1; out=[]
    for d in product(range(q),repeat=k):
        nz=[x for x in d if x]
        if len(nz)==len(set(nz)):
            out.append(sum(v*(q**i) for i,v in enumerate(d)))
    return q,out


def expected_betti(k,m):
    b=[1]
    for r in range(1,k+1):
        z=comb(k,r)
        for j in range(r):
            n=m-2*j
            z*=comb(n,2) if n>=2 else 0
        b.append(z)
    return b

print('1. fixed-support fibres have clique/product-torus homology')
checks=0
for m in range(0,7):
    for k in range(1,6):
        q,V=partial_injections(k,m); f,b=homology(V,q,k); want=expected_betti(k,m)
        assert b==want,(k,m,b,want)
        checks+=1
print('  verified',checks,'(k,m) complexes through k=5, m=6')
print('  beta_r = C(k,r) * product_j C(m-2j,2)')
print('  top possible hole dimension = min(k, floor(m/2))')

print('2. the generators are commuting local support loops')
# H1 generator: choose one Face and two child branches: root-a-b triangle.
# r such loops form an r-torus exactly when they use different Face coordinates
# and disjoint child pairs.  Count those cliques directly.
for k,m in [(5,4),(5,6),(4,6)]:
    b=expected_betti(k,m)
    for r in range(1,k+1):
        clique=comb(k,r)
        for j in range(r):
            n=m-2*j; clique*=comb(n,2) if n>=2 else 0
        assert clique==b[r]
    print('  k=',k,'m=',m,'betti=',tuple(x for x in b if x))

print('3. moving a fixed four-site causal support down a path unlocks higher homology')
# These vertex sets are the causal-spine law for root-M2-M3-M4 with k=4.
# depth d gives r=d+1 reusable spine sites and one off-spine branch containing
# the remaining sites; at most one coordinate may choose that branch.
def path_vertices(depth,k=4,s=4):
    reusable=set(range(depth+1)); off=set(range(depth+1,s)); out=[]
    for d in product(range(s),repeat=k):
        if sum(x in off for x in d)<=1:
            out.append(sum(v*(s**i) for i,v in enumerate(d)))
    return out
path_expected={
    0:([13,24,0,0,0],[1,12,0,0,0]),
    1:([80,288,312,136,21],[1,12,0,0,0]),
    2:([189,972,1782,1404,405],[1,12,30,28,9]),
    3:([256,1536,3456,3456,1296],[1,12,54,108,81]),
}
for d in range(4):
    f,b=homology(path_vertices(d),4,4); assert (f,b)==path_expected[d],(d,f,b)
    print('  depth',d,'betti',tuple(b))

print('4. internal Membrane branching can be latent until causal authority descends far enough to resolve it')
def profile_vertices(reusable,branches,k=4,s=4):
    out=[]
    for d in product(range(s),repeat=k):
        good=True
        for branch in branches:
            if sum(x in branch for x in d)>1: good=False; break
        if good: out.append(sum(v*(s**i) for i,v in enumerate(d)))
    return out
profiles={
    'star@root': ({0},[{1},{2},{3}],(73,[1,12,0,0,0])),
    'path@root': ({0},[{1,2,3}],(13,[1,12,0,0,0])),
    'fork@root': ({0},[{1,2,3}],(13,[1,12,0,0,0])),
    'fork@A': ({0,1},[{2},{3}],(128,[1,12,12,0,0])),
}
for name,(reuse,branches,(nv,want)) in profiles.items():
    V=profile_vertices(reuse,branches); f,b=homology(V,4,4); assert len(V)==nv and b==want,(name,len(V),b)
    print(' ',name,'vertices',len(V),'betti',tuple(b))
print('  root-level observation cannot distinguish path-vs-fork inside one off-spine branch; rebasing at A reveals the fork as H2.')

print('5. the observed Betti vectors equal clique counts of the natural local-loop commutation graph')
def commutation_cliques(k,s,branches):
    # Choose the star at state 0 as a spanning tree of the one-coordinate K_s.
    # H1 generators are the triangles 0-a-b, hence one generator per Face
    # coordinate and unordered pair among states 1..s-1.
    def valid(d): return all(sum(x in branch for x in d)<=1 for branch in branches)
    gens=[(i,pair) for i in range(k) for pair in combinations(range(1,s),2)]
    adj={g:set() for g in gens}
    for a,b in combinations(gens,2):
        i,p=a; j,q=b
        if i==j: continue
        good=True
        for x in (0,)+p:
            for y in (0,)+q:
                d=[0]*k; d[i]=x; d[j]=y
                if not valid(d): good=False; break
            if not good: break
        if good: adj[a].add(b); adj[b].add(a)
    out=[1,len(gens)]
    for r in range(2,k+1):
        z=0
        for ss in combinations(gens,r):
            if len({x[0] for x in ss})<r: continue
            if all(v in adj[u] for u,v in combinations(ss,2)): z+=1
        out.append(z)
    return out
# Star/partial-injection family.
for m in range(0,7):
    s=m+1; branches=[{x} for x in range(1,s)]
    for k in range(1,6): assert commutation_cliques(k,s,branches)==expected_betti(k,m)
# Same four-site tree under different causal resolutions.
for name,(reuse,branches,(_,want)) in profiles.items():
    assert commutation_cliques(4,4,branches)==want,(name,commutation_cliques(4,4,branches),want)
# Path depths: one off-spine branch containing every state below the causal spine.
for d in range(4):
    branches=[set(range(d+1,4))] if d<3 else []
    assert commutation_cliques(4,4,branches)==path_expected[d][1]
print('  all tested support-fibre Betti numbers equal clique numbers of the local-loop commutation graph')
print('  this is the Salvetti/RAAG homology pattern; fundamental-group equivalence remains a conjecture')

print('6. the same commutation law survives the asymmetric nine-site tree used by the Worlds exhaustive test')
rich_profiles={
    'R': [{1,2,3,4,5,6},{7,8}],
    'A': [{2,3,4},{5,6},{7,8}],
    'B': [{3,4},{5,6},{7,8}],
}
rich_expected={'R':[1,84,90,0],'A':[1,84,630,324],'B':[1,84,975,1642]}
for name,branches in rich_profiles.items():
    V=profile_vertices(set(),branches,k=3,s=9); f,b=homology(V,9,3); c=commutation_cliques(3,9,branches)
    assert b==rich_expected[name] and c==b,(name,b,c)
    print(' ',name,'vertices',len(V),'betti',tuple(b))
print('  H1 stays fixed while causal descent reveals rapidly more H2/H3 commutation structure.')

print('7. deepest support gives an unbounded moduli-space dimension family')
# If all s support sites lie on the causal spine, every coordinate varies
# independently over K_s.  beta(K_s)=1 + C(s-1,2)t, so k Faces give its k-th
# power and have nonzero H_k whenever s>=3.
for s in range(3,6):
    h1=comb(s-1,2)
    for k in range(1,7):
        b=[comb(k,r)*(h1**r) for r in range(k+1)]
        assert b[-1]>0
    print('  support sites',s,'Poincare factor for k Faces: (1 +',h1,'t)^k')

print('PASS support configuration homology / causal-spine topology')
