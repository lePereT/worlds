#!/usr/bin/env python3
"""GF(2) cubical homology of the finite realisation fibres.

A coordinate has q states: absent, root-hosted, then q-2 sibling Membrane hosts.
An elementary edge changes one coordinate between any two states.  A k-cube is
present when k independent coordinate edges have all 2^k vertices in the lawful
or developable vertex set.  This is an experimental realisation-space complex,
not a proposed Worlds carrier.
"""
from itertools import combinations, product
import sys

def decode(code,q):
    d=[]
    for _ in range(6): d.append(code%q); code//=q
    return tuple(d)

def analyse(q,path,label):
    V={int(x) for x in open(path) if x.strip()}; powers=[q**i for i in range(6)]; pairs=list(combinations(range(q),2))
    def encode(d): return sum(x*powers[i] for i,x in enumerate(d))
    def cells(k):
        # Canonical enumeration by coordinate-wise minimal corner.  Each cell is
        # generated once from its lowest vertex, avoiding the enormous ambient
        # q^6 * C(q,2)^k search.
        if k==0: return [decode(c,q) for c in sorted(V)]
        out=[]
        for code in sorted(V):
            base=decode(code,q)
            for act in combinations(range(6),k):
                choices=[range(base[i]+1,q) for i in act]
                if any(len(c)==0 for c in choices): continue
                for uppers in product(*choices):
                    spec=list(base)
                    for i,u in zip(act,uppers): spec[i]=(base[i],u)
                    good=True
                    for bits in product((0,1),repeat=k):
                        d=list(base)
                        for i,u,b in zip(act,uppers,bits): d[i]=u if b else base[i]
                        if encode(d) not in V: good=False; break
                    if good: out.append(tuple(spec))
        return out
    C=[cells(k) for k in range(7)]
    def boundary(c):
        out=[]
        for i,x in enumerate(c):
            if isinstance(x,tuple):
                for v in x:
                    y=list(c); y[i]=v; out.append(tuple(y))
        return out
    def rank(cols):
        piv={}
        for x in cols:
            while x:
                p=x.bit_length()-1
                if p in piv: x ^= piv[p]
                else: piv[p]=x; break
        return len(piv)
    ranks=[0]*7
    for k in range(1,7):
        idx={c:i for i,c in enumerate(C[k-1])}; cols=[]
        for c in C[k]:
            x=0
            for f in boundary(c): x ^= 1<<idx[f]
            cols.append(x)
        ranks[k]=rank(cols)
    betti=[len(C[k])-ranks[k]-(ranks[k+1] if k<6 else 0) for k in range(7)]
    f=[len(x) for x in C]
    chi=sum((1 if k%2==0 else -1)*x for k,x in enumerate(f))
    print(label,'q=',q,'f=',f,'ranks=',ranks[1:],'betti=',betti,'chi=',chi)
    return f,betti,chi,C

def main():
    mode=sys.argv[1]
    if mode=='developable':
        q=int(sys.argv[2]); f,b,chi,_=analyse(q,sys.argv[3],f'developable(q={q})')
        expected={
            2:([10,13,4,0,0,0,0],[1,0,0,0,0,0,0],1),
            3:([35,77,44,6,0,0,0],[1,5,0,0,0,0,0],-4),
            4:([120,386,358,106,8,0,0],[1,15,8,0,0,0,0],-6),
            5:([385,1690,2284,1116,180,6,0],[1,30,66,0,0,0,0],37),
            6:([1118,6443,11888,8472,2220,156,0],[1,50,276,72,0,0,0],155),
        }[q]
        assert (f,b,chi)==expected,(f,b,chi,expected)
    elif mode=='lawful4':
        f,b,chi,_=analyse(4,sys.argv[2],'lawful(q=4)')
        assert f==[2304,16940,49636,74677,61616,26697,4770]
        assert b==[1,18,135,220,175,74,13]
        assert chi==12
    else: raise SystemExit('mode: developable q file | lawful4 file')
if __name__=='__main__': main()
