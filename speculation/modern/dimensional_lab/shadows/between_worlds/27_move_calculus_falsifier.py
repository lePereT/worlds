#!/usr/bin/env python3
"""Same exact Worlds vertices, different elementary moves, different topology.

This is a direct falsifier for the idea that a higher moduli space is determined
by its set of exact Worlds alone.  We keep the same lawful support assignments
and compare two equally simple move calculi:

jump:      one Face may be rehosted directly to any other support site;
tree-local: one Face may move only across one Membrane parent/child edge.

Independent coordinate moves fill cubes whenever every corner remains lawful.
The jump complex has the RAAG topology seen in the deep-fibre work.  The
parent/child complex has trivial pi_1 and trivial reduced homology in every
asymmetric-tree profile tested here.
"""
from itertools import product, combinations
from collections import deque,Counter

TREE_EDGES=[(0,1),(1,2),(2,3),(3,4),(1,5),(5,6),(0,7),(7,8)]
PROFILES={
    'R': [{1,2,3,4,5,6},{7,8}],
    'A': [{2,3,4},{5,6},{7,8}],
    'B': [{3,4},{5,6},{7,8}],
}
JUMP_BETTI={
    'R': [1,84,90,0],
    'A': [1,84,630,324],
    'B': [1,84,975,1642],
}


def valid_words(k,s,branches):
    return [v for v in product(range(s),repeat=k)
            if all(sum(x in br for x in v)<=1 for br in branches)]


def adjacency(s,mode):
    A={i:set() for i in range(s)}
    edges=(TREE_EDGES if mode=='local' else list(combinations(range(s),2)))
    for a,b in edges:A[a].add(b);A[b].add(a)
    return A


def cells(V,k,A,r):
    V=set(V)
    if r==0:return sorted(V)
    out=[]
    for base in sorted(V):
        for act in combinations(range(k),r):
            opts=[]
            for i in act: opts.append([b for b in A[base[i]] if b>base[i]])
            if any(not x for x in opts):continue
            for ups in product(*opts):
                spec=list(base)
                for i,u in zip(act,ups):spec[i]=(base[i],u)
                good=True
                for bits in product((0,1),repeat=r):
                    d=list(base)
                    for i,u,bb in zip(act,ups,bits):d[i]=u if bb else base[i]
                    if tuple(d) not in V:good=False;break
                if good:out.append(tuple(spec))
    return out


def rank(cols):
    piv={}
    for x in cols:
        while x:
            p=x.bit_length()-1
            if p in piv:x^=piv[p]
            else:piv[p]=x;break
    return len(piv)


def homology(V,k,A):
    C=[cells(V,k,A,r) for r in range(k+1)]; ranks=[0]*(k+1)
    for r in range(1,k+1):
        idx={c:i for i,c in enumerate(C[r-1])};cols=[]
        for c in C[r]:
            x=0
            for i,z in enumerate(c):
                if isinstance(z,tuple):
                    for v in z:
                        y=list(c);y[i]=v;x^=1<<idx[tuple(y)]
            cols.append(x)
        ranks[r]=rank(cols)
    bet=[len(C[r])-ranks[r]-(ranks[r+1] if r<k else 0) for r in range(k+1)]
    return list(map(len,C)),bet

# Minimal pi1 presentation for the local move complex, used to check that
# trivial H1 is not merely hiding a perfect nontrivial fundamental group.
def free_reduce(w):
    st=[]
    for x in w:
        if st and st[-1]==-x:st.pop()
        else:st.append(x)
    while len(st)>1 and st[0]==-st[-1]:st=st[1:-1]
    return tuple(st)
def inv(w):return tuple(-x for x in reversed(w))
def subst(w,g,repl):
    out=[]
    for x in w:
        if x==g:out.extend(repl)
        elif x==-g:out.extend(inv(repl))
        else:out.append(x)
    return free_reduce(out)
def simplify(n,rels):
    active=set(range(1,n+1));rels=[free_reduce(r) for r in rels];rels=[r for r in rels if r]
    while True:
        move=None
        for r in rels:
            if len(r)==1:move=(abs(r[0]),());break
        if move is None:
            for r in rels:
                if len(r)==2 and abs(r[0])!=abs(r[1]):
                    a,b=r;ga,gb=abs(a),abs(b)
                    if ga>gb:
                        e=(-1 if b>0 else 1)*(1 if a>0 else -1);move=(ga,(gb if e>0 else -gb,))
                    else:
                        e=(-1 if a>0 else 1)*(1 if b>0 else -1);move=(gb,(ga if e>0 else -ga,))
                    break
        if move is None:break
        g,repl=move;rels=[subst(r,g,repl) for r in rels];rels=[r for r in rels if r];active.discard(g)
    return active,rels

def pi1_local(V,k,A):
    VS=set(V);E=[];em={}
    for v in V:
        for i in range(k):
            for b in A[v[i]]:
                w=list(v);w[i]=b;w=tuple(w)
                if w in VS:
                    key=frozenset((v,w))
                    if key not in em:em[key]=len(E);E.append((v,w,i))
    S={}
    for v in V:
        for i,j in combinations(range(k),2):
            for bi in A[v[i]]:
                for bj in A[v[j]]:
                    vi=list(v);vi[i]=bi;vi=tuple(vi);vj=list(v);vj[j]=bj;vj=tuple(vj);vij=list(v);vij[i]=bi;vij[j]=bj;vij=tuple(vij)
                    if vi in VS and vj in VS and vij in VS:
                        S[tuple(sorted((v,vi,vj,vij)))]=(v,vi,vij,vj)
    base=(0,)*k;adj={v:[] for v in V}
    for ei,(a,b,_) in enumerate(E):adj[a].append((b,ei));adj[b].append((a,ei))
    par={base:(None,None)};q=deque([base])
    while q:
        v=q.popleft()
        for w,ei in adj[v]:
            if w not in par:par[w]=(v,ei);q.append(w)
    assert len(par)==len(V)
    tree={ei for v,(p,ei) in par.items() if ei is not None}
    gens={ei:i+1 for i,ei in enumerate(e for e in range(len(E)) if e not in tree)}
    def tok(a,b):
        ei=em[frozenset((a,b))]
        if ei in tree:return None
        u,v,_=E[ei];g=gens[ei];return g if (a,b)==(u,v) else -g
    rel=[]
    for v,vi,vij,vj in S.values():
        w=[]
        for a,b in ((v,vi),(vi,vij),(vij,vj),(vj,v)):
            t=tok(a,b)
            if t:w.append(t)
        rel.append(tuple(w))
    active,rels=simplify(len(gens),rel)
    return len(E),len(S),len(gens),len(active),len(rels),Counter(map(len,rels))

print('same exact-World vertex sets, two move calculi')
for name,branches in PROFILES.items():
    V=valid_words(3,9,branches)
    jump=adjacency(9,'jump'); local=adjacency(9,'local')
    jf,jb=homology(V,3,jump); lf,lb=homology(V,3,local)
    assert jb==JUMP_BETTI[name],(name,jb)
    assert lb==[1,0,0,0],(name,lb)
    pres=pi1_local(V,3,local)
    assert pres[3]==0 and pres[4]==0,(name,pres)
    print(' ',name,'vertices',len(V),
          'jump f',tuple(jf),'jump beta',tuple(jb),
          'tree-local f',tuple(lf),'tree-local beta',tuple(lb),
          'tree-local pi1 after Tietze',pres[3:])

print('PASS: topology is not determined by the exact Worlds alone; it depends on the chosen between-Worlds move calculus')
