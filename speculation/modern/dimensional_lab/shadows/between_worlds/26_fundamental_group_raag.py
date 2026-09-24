#!/usr/bin/env python3
"""Fundamental-group pressure on the between-Worlds support moduli.

For the liberal one-coordinate "jump" atlas used in the deep-fibre work, build
the standard pi_1 presentation of the cubical 2-skeleton:

* choose a spanning tree of the 1-skeleton;
* one generator for every non-tree edge;
* one relator for every commuting square.

Then perform only elementary Tietze eliminations forced by length-1 and length-2
relators.  In every tested fibre the remaining presentation is exactly a RAAG
presentation: one generator for each local support triangle and only commutator
relations.  The resulting commutation graph is independently reconstructed from
the causal-spine branch law and checked for graph isomorphism.
"""
from itertools import product, combinations
from collections import deque, Counter
import networkx as nx


def valid_words(k,s,branches):
    return [v for v in product(range(s),repeat=k)
            if all(sum(x in br for x in v)<=1 for br in branches)]


def jump_complex(k,s,branches):
    V=valid_words(k,s,branches); VS=set(V)
    E=[]; edge_index={}
    for v in V:
        for i in range(k):
            for b in range(v[i]+1,s):
                w=list(v); w[i]=b; w=tuple(w)
                if w in VS:
                    edge_index[frozenset((v,w))]=len(E)
                    E.append((v,w,i))
    squares=[]
    for v in V:
        for i,j in combinations(range(k),2):
            for bi in range(v[i]+1,s):
                vi=list(v);vi[i]=bi;vi=tuple(vi)
                if vi not in VS: continue
                for bj in range(v[j]+1,s):
                    vj=list(v);vj[j]=bj;vj=tuple(vj)
                    if vj not in VS: continue
                    vij=list(v);vij[i]=bi;vij[j]=bj;vij=tuple(vij)
                    if vij in VS: squares.append((v,vi,vij,vj))
    return V,E,edge_index,squares


def free_reduce(w):
    st=[]
    for x in w:
        if st and st[-1]==-x: st.pop()
        else: st.append(x)
    while len(st)>1 and st[0]==-st[-1]: st=st[1:-1]
    return tuple(st)


def inv(w): return tuple(-x for x in reversed(w))


def subst_word(w,g,repl):
    out=[]
    for x in w:
        if x==g: out.extend(repl)
        elif x==-g: out.extend(inv(repl))
        else: out.append(x)
    return free_reduce(out)


def tietze_short(n,rels):
    """Eliminate only relations g=1 and g=h^{+-1}; no heuristic group rewriting."""
    active=set(range(1,n+1)); rels=[free_reduce(r) for r in rels]
    rels=[r for r in rels if r]
    while True:
        move=None
        for r in rels:
            if len(r)==1:
                move=(abs(r[0]),()); break
        if move is None:
            for r in rels:
                if len(r)==2 and abs(r[0])!=abs(r[1]):
                    a,b=r; ga,gb=abs(a),abs(b)
                    if ga>gb:
                        exp=(-1 if b>0 else 1)*(1 if a>0 else -1)
                        move=(ga,(gb if exp>0 else -gb,))
                    else:
                        exp=(-1 if a>0 else 1)*(1 if b>0 else -1)
                        move=(gb,(ga if exp>0 else -ga,))
                    break
        if move is None: break
        g,repl=move
        rels=[subst_word(r,g,repl) for r in rels]
        rels=[r for r in rels if r]
        active.discard(g)
    return active,rels


def presentation(k,s,branches):
    V,E,edge_index,S=jump_complex(k,s,branches); base=(0,)*k
    adj={v:[] for v in V}
    for ei,(a,b,_) in enumerate(E):
        adj[a].append((b,ei)); adj[b].append((a,ei))
    parent={base:(None,None)}; q=deque([base])
    while q:
        v=q.popleft()
        for w,ei in adj[v]:
            if w not in parent:
                parent[w]=(v,ei); q.append(w)
    assert len(parent)==len(V)
    tree={ei for v,(p,ei) in parent.items() if ei is not None}
    gen_of={ei:i+1 for i,ei in enumerate(e for e in range(len(E)) if e not in tree)}
    def token(a,b):
        ei=edge_index[frozenset((a,b))]
        if ei in tree: return None
        u,v,_=E[ei]; g=gen_of[ei]
        return g if (a,b)==(u,v) else -g
    rel=[]
    for v,vi,vij,vj in S:
        w=[]
        for a,b in ((v,vi),(vi,vij),(vij,vj),(vj,v)):
            t=token(a,b)
            if t is not None: w.append(t)
        rel.append(tuple(w))
    active,rels=tietze_short(len(gen_of),rel)
    return V,E,S,active,rels


def comm_pair(w):
    if len(w)!=4: return None
    a,b,c,d=w
    if c==-a and d==-b and abs(a)!=abs(b): return tuple(sorted((abs(a),abs(b))))
    if c==-b and d==-a and abs(a)!=abs(b): return tuple(sorted((abs(a),abs(b))))
    return None


def actual_commutation_graph(active,rels):
    G=nx.Graph(); G.add_nodes_from(active)
    for w in rels:
        p=comm_pair(w)
        assert p is not None,('non-commutator survivor',w)
        G.add_edge(*p)
    return G


def candidate_graph(k,s,branches):
    def valid(v): return all(sum(x in br for x in v)<=1 for br in branches)
    gens=[(i,p) for i in range(k) for p in combinations(range(1,s),2)]
    G=nx.Graph();G.add_nodes_from(gens)
    for a,b in combinations(gens,2):
        i,p=a; j,q=b
        if i==j: continue
        good=True
        for x in (0,)+p:
            for y in (0,)+q:
                d=[0]*k;d[i]=x;d[j]=y
                if not valid(d): good=False; break
            if not good: break
        if good:G.add_edge(a,b)
    return G


def clique_counts(G,maxdim):
    out=[1]
    for r in range(1,maxdim+1):
        out.append(sum(1 for c in nx.enumerate_all_cliques(G) if len(c)==r))
    return out

cases=[
    ('star k2 m4',2,5,[{1},{2},{3},{4}]),
    ('star k3 m4',3,5,[{1},{2},{3},{4}]),
    ('path root',4,4,[{1,2,3}]),
    ('path depth2',4,4,[{3}]),
    ('asymmetric R',3,9,[{1,2,3,4,5,6},{7,8}]),
    ('asymmetric A',3,9,[{2,3,4},{5,6},{7,8}]),
    ('asymmetric B',3,9,[{3,4},{5,6},{7,8}]),
]

print('fundamental-group presentations of between-Worlds jump atlases')
for name,k,s,branches in cases:
    V,E,S,active,rels=presentation(k,s,branches)
    A=actual_commutation_graph(active,rels); C=candidate_graph(k,s,branches)
    assert nx.is_isomorphic(A,C),(name,A.number_of_nodes(),A.number_of_edges(),C.number_of_nodes(),C.number_of_edges())
    unique_rel_edges=A.number_of_edges()
    assert len(active)==C.number_of_nodes()
    print(' ',name,
          'worlds',len(V),'moves',len(E),'squares',len(S),
          'pi1_generators',len(active),'unique_commutators',unique_rel_edges,
          'cliques',tuple(clique_counts(A,k)))

print('PASS: every tested standard pi1 presentation Tietze-reduces to the independently predicted RAAG commutation graph')
