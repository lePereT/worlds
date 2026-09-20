local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq=T.ok,T.eq
local I={{1,0},{0,1}}; local X={{0,1},{1,0}}; local Z={{1,0},{0,-1}}
local XI=T.kron(X,I); local IX=T.kron(I,X); local XX=T.kron(X,X)
local IZ=T.kron(I,Z); local ZI=T.kron(Z,I); local ZZ=T.kron(Z,Z)
local XZ=T.kron(X,Z); local ZX=T.kron(Z,X)
local smallXZ=T.mm(X,Z); local YY=T.scale(T.kron(smallXZ,smallXZ),-1)
local ops={A=XI,B=IX,C=XX,D=IZ,E=ZI,F=ZZ,G=XZ,H=ZX,I=YY}
local contexts={
  {'A','B','C'}, {'D','E','F'}, {'G','H','I'},
  {'A','D','G'}, {'B','E','H'}, {'C','F','I'}
}

-- Worlds carries the overlap cover: six face-free context Strands over nine exact
-- observable Points. This is non-laminar by design but entirely ordinary
-- Point-Strand incidence.
local b=W.builder(); local m=b:membrane(nil,'two-qubit-observables'); local pts={}; for name in pairs(ops) do pts[name]=b:point(m,name) end
local strands={}; for ci,c in ipairs(contexts) do strands[ci]=b:strand(m,{pts[c[1]],pts[c[2]],pts[c[3]]},'context-'..ci) end
local cover=b:finish(); eq(#cover:faces(),0); eq(#cover:egress(),6)
for name,p in pairs(pts) do local seen=0; for _,s in ipairs(strands) do for _,q in ipairs(W.points(s)) do if q==p then seen=seen+1 end end end; eq(seen,2,'each observable lies in exactly two overlapping contexts') end

-- Derive the local classical parity laws from actual quantum operator products.
local signs={}
for ci,c in ipairs(contexts) do
  local A,B,C=ops[c[1]],ops[c[2]],ops[c[3]]
  ok(T.commute(A,B) and T.commute(A,C) and T.commute(B,C),'each context is a commuting quantum family')
  local sign=T.is_identity_up_to_sign(T.mm(T.mm(A,B),C)); ok(sign~=nil,'context product is +/- identity'); signs[ci]=sign
  local local_count=0
  for a=-1,1,2 do for bb=-1,1,2 do for cc=-1,1,2 do if a*bb*cc==sign then local_count=local_count+1 end end end end
  eq(local_count,4,'each commuting context has a four-point classical outcome space under its parity law')
end
for i=1,5 do eq(signs[i],1) end; eq(signs[6],-1,'last column carries the quantum contextual sign')

-- Yet those six perfectly classical local outcome spaces cannot be glued into one
-- global +/-1 valuation of the nine shared observables.
local names={'A','B','C','D','E','F','G','H','I'}; local index={}; for i,n in ipairs(names) do index[n]=i end
local function satisfies(bits,skip)
  for ci,c in ipairs(contexts) do if ci~=skip then
    local prod=1; for _,name in ipairs(c) do prod=prod*bits[index[name]] end
    if prod~=signs[ci] then return false end
  end end
  return true
end
local global=0; for mask=0,511 do local vals={}; for i=1,9 do vals[i]=((math.floor(mask/2^(i-1))%2)==0) and 1 or -1 end; if satisfies(vals,nil) then global=global+1 end end
eq(global,0,'locally classical quantum contexts have no global classical section')
for skip=1,6 do local c=0; for mask=0,511 do local vals={}; for i=1,9 do vals[i]=((math.floor(mask/2^(i-1))%2)==0) and 1 or -1 end; if satisfies(vals,skip) then c=c+1 end end; eq(c,16,'remove one context and global classical valuations return') end

print('contextual classical islands: '..T.count()..' assertions passed')
print('  commuting quantum subtheories yield ordinary local classical sample spaces; contextuality is precisely the obstruction to gluing them globally')
