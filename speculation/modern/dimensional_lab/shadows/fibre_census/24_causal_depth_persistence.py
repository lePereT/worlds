#!/usr/bin/env python3
"""Persistent homology as causal support descends a fixed Membrane path.

The same four host Membranes and same four-Face causal chain are held fixed.
Moving the authority-support down the path relaxes off-spine exclusivity, giving
nested realisation complexes X0 <= X1 <= X2 <= X3.

The experiment computes inclusion ranks on homology over GF(2), not merely
Betti numbers.  Every existing class survives; descending causality only births
new higher-dimensional classes in this family.
"""
from itertools import combinations,product
Q=N=4

def vertices(depth):
    off=set(range(depth+1,Q)); V=set()
    for d in product(range(Q),repeat=N):
        if sum(x in off for x in d)<=1: V.add(d)
    return V
VS=[vertices(d) for d in range(4)]
assert all(VS[d] <= VS[d+1] for d in range(3))

def cells(V,k):
    if k==0:return sorted(V)
    out=[]
    for base in sorted(V):
        for act in combinations(range(N),k):
            opts=[range(base[i]+1,Q) for i in act]
            if any(len(x)==0 for x in opts):continue
            for ups in product(*opts):
                spec=list(base)
                for i,u in zip(act,ups):spec[i]=(base[i],u)
                good=True
                for bits in product((0,1),repeat=k):
                    d=list(base)
                    for i,u,b in zip(act,ups,bits):d[i]=u if b else base[i]
                    if tuple(d) not in V:good=False;break
                if good:out.append(tuple(spec))
    return out

def boundary(c):
    for i,x in enumerate(c):
        if isinstance(x,tuple):
            for v in x:
                y=list(c);y[i]=v;yield tuple(y)

def add(x,basis):
    while x:
        p=x.bit_length()-1
        if p in basis:x^=basis[p]
        else:basis[p]=x;return True
    return False

def data(V):
    C=[cells(V,k) for k in range(N+1)]; I=[{c:i for i,c in enumerate(C[k])} for k in range(N+1)]
    kernels=[[] for _ in range(N+1)]; images=[{} for _ in range(N+1)]
    kernels[0]=[1<<i for i in range(len(C[0]))]
    for k in range(1,N+1):
        piv={}; ker=[]; im={}
        for j,c in enumerate(C[k]):
            col=0
            for f in boundary(c):col^=1<<I[k-1][f]
            add(col,im)
            x=col; track=1<<j
            while x:
                p=x.bit_length()-1
                if p in piv:
                    pv,pt=piv[p];x^=pv;track^=pt
                else:piv[p]=(x,track);break
            if x==0:ker.append(track)
        kernels[k]=ker;images[k-1]=im
    return C,I,kernels,images
D=[data(V) for V in VS]
def betti(d,k):return len(D[d][2][k])-len(D[d][3][k])

def inclusion_rank(a,b,k):
    Ca,Ia,Za,Ba=D[a]; Cb,Ib,Zb,Bb=D[b]
    basis=dict(Bb[k]); before=len(basis)
    for cyc in Za[k]:
        x=0;z=cyc
        while z:
            bit=z & -z; j=bit.bit_length()-1;z^=bit
            x^=1<<Ib[k][Ca[k][j]]
        add(x,basis)
    return len(basis)-before

BETTI=[
    [1,12,0,0,0],
    [1,12,0,0,0],
    [1,12,30,28,9],
    [1,12,54,108,81],
]
for d in range(4):
    got=[betti(d,k) for k in range(N+1)];assert got==BETTI[d],(d,got);print('depth',d,'betti',tuple(got))

print('adjacent inclusion ranks')
for d in range(3):
    ranks=[inclusion_rank(d,d+1,k) for k in range(N+1)]
    assert ranks==BETTI[d],(d,ranks,BETTI[d])
    print(' ',d,'->',d+1,tuple(ranks),'(all source classes persist)')

# Birth counts because no class dies along this filtration.
births=[]
prev=[0]*(N+1)
for d,b in enumerate(BETTI):
    born=[b[k]-prev[k] for k in range(N+1)];births.append(born);prev=b
print('births by support depth')
for d,b in enumerate(births):print(' ',d,tuple(b))
assert births==[[1,12,0,0,0],[0,0,0,0,0],[0,0,30,28,9],[0,0,24,80,72]]
print('PASS causal-depth persistent topology: descent reveals commuting higher structure without killing earlier classes')
