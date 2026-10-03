#!/usr/bin/env python3
"""Check whether the observed fibre homology is a mod-2 artefact.

The earlier census used GF(2), natural for unoriented cubical boundaries.  Here
we orient every experimental cube and recompute ranks over odd prime fields.
Matching Betti numbers do not prove integral torsion-freeness, but they rule out
2/3/5-characteristic surprises in the tested ranges.
"""
from itertools import combinations,product

MASKS={0,1<<4,1<<5,(1<<4)|(1<<5),(1<<3)|(1<<4),(1<<3)|(1<<4)|(1<<5),
       (1<<2)|(1<<3)|(1<<4),(1<<2)|(1<<3)|(1<<4)|(1<<5),
       (1<<1)|(1<<2)|(1<<3)|(1<<4),(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)}
EXPECTED={4:[1,15,8,0,0,0,0],5:[1,30,66,0,0,0,0],6:[1,50,276,72,0,0,0]}

def vertices(q):
    out=set()
    for d in product(range(q),repeat=6):
        mask=0; used=set(); good=True
        for i,s in enumerate(d):
            if s:
                mask|=1<<i
                if s>=2:
                    if s in used: good=False; break
                    used.add(s)
        if good and mask in MASKS: out.add(sum(s*q**i for i,s in enumerate(d)))
    return out

def analyse(q,p):
    V=vertices(q); pw=[q**i for i in range(6)]
    def dec(c):
        d=[]
        for _ in range(6):d.append(c%q);c//=q
        return tuple(d)
    def enc(d):return sum(v*pw[i] for i,v in enumerate(d))
    def cells(k):
        if k==0:return [dec(c) for c in sorted(V)]
        out=[]
        for code in sorted(V):
            base=dec(code)
            for act in combinations(range(6),k):
                opts=[range(base[i]+1,q) for i in act]
                if any(len(x)==0 for x in opts):continue
                for ups in product(*opts):
                    spec=list(base)
                    for i,u in zip(act,ups):spec[i]=(base[i],u)
                    good=True
                    for bits in product((0,1),repeat=k):
                        d=list(base)
                        for i,u,b in zip(act,ups,bits):d[i]=u if b else base[i]
                        if enc(d) not in V:good=False;break
                    if good:out.append(tuple(spec))
        return out
    C=[cells(k) for k in range(7)]
    def rank(cols):
        piv={}
        for col in cols:
            x=dict(col)
            while x:
                r=max(x)
                if r not in piv:
                    inv=pow(x[r],-1,p); x={i:(v*inv)%p for i,v in x.items() if v%p};piv[r]=x;break
                f=x[r];pv=piv[r]
                for i,v in pv.items():
                    z=(x.get(i,0)-f*v)%p
                    if z:x[i]=z
                    elif i in x:del x[i]
        return len(piv)
    ranks=[0]*7
    for k in range(1,7):
        idx={c:i for i,c in enumerate(C[k-1])};cols=[]
        for c in C[k]:
            active=[i for i,z in enumerate(c) if isinstance(z,tuple)]; col={}
            for pos,i in enumerate(active):
                lo,hi=c[i];sg=1 if pos%2==0 else -1
                for v,coef in ((hi,sg),(lo,-sg)):
                    y=list(c);y[i]=v;j=idx[tuple(y)];col[j]=(col.get(j,0)+coef)%p
                    if col[j]==0:del col[j]
            cols.append(col)
        ranks[k]=rank(cols)
    return [len(C[k])-ranks[k]-(ranks[k+1] if k<6 else 0) for k in range(7)]

for q,p in [(4,3),(4,5),(5,3),(5,5),(6,3)]:
    b=analyse(q,p); assert b==EXPECTED[q],(q,p,b,EXPECTED[q]); print('q=',q,'GF(',p,') betti=',tuple(b),sep='')
print('PASS coefficient-field pressure: no 2/3/5 Betti jump in tested executable fibres')
