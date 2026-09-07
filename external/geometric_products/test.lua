package.path='../../src/?.lua;../../src/?/init.lua;'..package.path
local W=require('worlds'); local G=W.Geometry
local function only(x) return x end
local N=0; local function ok(x,m) N=N+1; assert(x,m or ('assertion '..N)) end; local function eq(a,b,m) N=N+1; assert(a==b,'#'..N..' '..(m or 'eq')..': '..tostring(a)..' ~= '..tostring(b)) end
local vb=G.builder(); local vm=vb:membrane(nil,'vocabulary'); local R={}
for _,n in ipairs{'Unit','ReqGive','ReqTake','DoneGive','DoneTake','Entry','ReqPut','ReqTakeKey','DonePut','DoneTakeKey','ReqRemove','DoneRemove','ReqPop','DonePop','ReqObserve','DoneObserve','Control','A','B','C'} do R[n]=vb:point(vm,n) end
vb:finish()

local function tensor(parts) return W.Algebra.tensor(parts) end
local function cuts(base,proc) return assert(W.Cut.all(proc,{offers=base:egress()})) end
local function outcomes(base,proc,filter)
  local out={}; for _,c in ipairs(cuts(base,proc)) do if not filter or filter(c,proc) then out[#out+1]=select(1,W.Algebra.apply(base,proc,c)) end end; return out
end
local function count_role(g,role)
  local n=0; for _,s in ipairs(g:egress()) do if G.points(s)[1]==role then n=n+1 end end; return n
end
local function base_counter(n,reqs)
  local b=G.builder(); local m=b:membrane(nil,'counter'); local counter=b:point(m,'counter')
  for i=1,n do b:strand(m,{R.Unit,counter},'unit') end
  for _,q in ipairs(reqs or {}) do local call=b:point(m,q.id); b:strand(m,{R[q.role],call,counter},q.id) end
  return b:finish(),counter
end
local function give(id)
  local b=G.builder(); local m=b:membrane(nil,'give'); local call=b:point(m,id); local c=b:point(m,'counter')
  local req=b:strand(m,{R.ReqGive,call,c}); local unit=b:strand(m,{R.Unit,c}); local done=b:strand(m,{R.DoneGive,call,c}); b:face(m,{req},{unit,done})
  return b:finish(),{unit=unit}
end
local function take(id,n)
  local b=G.builder(); local m=b:membrane(nil,'take'); local call=b:point(m,id); local c=b:point(m,'counter'); local ins={b:strand(m,{R.ReqTake,call,c})}; local units={}
  for i=1,(n or 1) do units[i]=b:strand(m,{R.Unit,c}); ins[#ins+1]=units[i] end
  local done=b:strand(m,{R.DoneTake,call,c}); b:face(m,ins,{done}); return b:finish(),{units=units}
end

-- 1-4 Counter: each is tensor; together is tensor plus sibling Cut.
do
  local base=base_counter(0,{{id='g',role='ReqGive'},{id='t',role='ReqTake'}}); local g,gm=give('g'); local t,tm=take('t')
  local each=tensor{g,t}; eq(#cuts(base,each),0,'each cannot see sibling-produced Unit')
  local together=W.Algebra.close({g,t},{{gm.unit,tm.units[1]}}); local xs=outcomes(base,together); eq(#xs,1); eq(count_role(xs[1],R.Unit),0)
  local rev=W.Algebra.close({t,g},{{gm.unit,tm.units[1]}}); eq(#outcomes(base,rev),1,'sibling order irrelevant')
end

do
  local base=base_counter(2,{{id='a',role='ReqTake'},{id='b',role='ReqTake'}}); local a=take('a'); local b=take('b'); local each=tensor{a,b}; local cs=cuts(base,each); eq(#cs,4,'two Unit assignments x two unpinned request assignments'); for _,c in ipairs(cs) do eq(count_role(select(1,W.Algebra.apply(base,each,c)),R.Unit),0) end
end

do
  local base=base_counter(1,{{id='a',role='ReqTake'},{id='b',role='ReqTake'}}); eq(#cuts(base,tensor{only(take('a')),only(take('b'))}),0,'scarcity constrains siblings')
end

do
  local base=base_counter(1,{{id='g1',role='ReqGive'},{id='g2',role='ReqGive'}}); local xs=outcomes(base,only(tensor{only(give('g1')),only(give('g2'))})); eq(#xs,2,'two unpinned request assignments'); for _,g in ipairs(xs) do eq(count_role(g,R.Unit),3,'positive outputs combine but do not supply readiness under tensor') end
end

-- 5 take(2) may use one sibling Unit only after internal closure.
do
  local base=base_counter(1,{{id='g',role='ReqGive'},{id='t',role='ReqTake'}}); local g,gm=give('g'); local t,tm=take('t',2); eq(#cuts(base,tensor{g,t}),0)
  local c1=W.Algebra.close({g,t},{{gm.unit,tm.units[1]}}); local c2=W.Algebra.close({g,t},{{gm.unit,tm.units[2]}}); eq(#outcomes(base,c1),1); eq(#outcomes(base,c2),1)
end

local function base_map(entries,requests)
  local b=G.builder(); local m=b:membrane(nil,'map'); local map=b:point(m,'map'); local keys={}
  local function key(k) if not keys[k] then keys[k]=b:point(m,k) end return keys[k] end
  for _,k in ipairs(entries or {}) do b:strand(m,{R.Entry,map,key(k)},'entry-'..k) end
  for _,q in ipairs(requests or {}) do local call=b:point(m,q.id); local pts={R[q.role],call,map}; if q.key then pts[#pts+1]=key(q.key) end; b:strand(m,pts,q.id) end
  return b:finish(),map,keys
end
local function put(id)
  local b=G.builder(); local m=b:membrane(nil,'put'); local call=b:point(m,id); local map=b:point(m,'map'); local key=b:point(m,'key'); local req=b:strand(m,{R.ReqPut,call,map,key}); local entry=b:strand(m,{R.Entry,map,key}); local done=b:strand(m,{R.DonePut,call,map}); b:face(m,{req},{entry,done}); return b:finish(),{entry=entry,key=key}
end
local function take_key(id)
  local b=G.builder(); local m=b:membrane(nil,'take'); local call=b:point(m,id); local map=b:point(m,'map'); local key=b:point(m,'key'); local req=b:strand(m,{R.ReqTakeKey,call,map,key}); local entry=b:strand(m,{R.Entry,map,key}); local done=b:strand(m,{R.DoneTakeKey,call,map,key}); b:face(m,{req,entry},{done}); return b:finish(),{entry=entry,key=key}
end
-- 6 keyed sibling supply is ordinary Point-preserving cut.
do
  local base=base_map({},{{id='p',role='ReqPut',key='z'},{id='t',role='ReqTakeKey',key='z'}}); local p,pm=put('p'); local t,tm=take_key('t'); eq(#cuts(base,tensor{p,t}),0); local joined=W.Algebra.close({p,t},{{pm.entry,tm.entry}}); eq(#outcomes(base,joined),1); eq(count_role(outcomes(base,joined)[1],R.Entry),0)
end

local function remove(id)
  local b=G.builder(); local m=b:membrane(nil,'remove'); local call=b:point(m,id); local map=b:point(m,'map'); local key=b:point(m,'key'); local req=b:strand(m,{R.ReqRemove,call,map,key}); local entry=b:strand(m,{R.Entry,map,key}); local done=b:strand(m,{R.DoneRemove,call,map}); b:face(m,{req,entry},{done}); return b:finish(),{entry=entry,key=key}
end
local function pop(id)
  local b=G.builder(); local m=b:membrane(nil,'pop'); local call=b:point(m,id); local map=b:point(m,'map'); local key=b:point(m,'key'); local req=b:strand(m,{R.ReqPop,call,map}); local entry=b:strand(m,{R.Entry,map,key}); local done=b:strand(m,{R.DonePop,call,map,key}); b:face(m,{req,entry},{done}); return b:finish(),{entry=entry,key=key}
end
-- 7 whole-candidate Theory sees sibling consumption without sibling positive supply.
do
  local base,map,keys=base_map({'a','b','c'},{{id='r',role='ReqRemove',key='a'},{id='p',role='ReqPop'}}); local rem,rm=remove('r'); local pp,pm=pop('p'); local each,eimg=W.Algebra.tensor{rem,pp}; local rm_entry=eimg[1].strands[rm.entry]; local pm_entry=eimg[2].strands[pm.entry]; local ranks={[keys.a]=1,[keys.b]=2,[keys.c]=3}; local accepted=0
  for _,c in ipairs(cuts(base,each)) do local rs=c:strand(rm_entry); local ps=c:strand(pm_entry); local min
    for _,s in ipairs(base:egress()) do if G.points(s)[1]==R.Entry and s~=rs then local k=G.points(s)[3]; if not min or ranks[k]<ranks[G.points(min)[3]] then min=s end end end
    if ps==min then accepted=accepted+1 end
  end
  eq(accepted,1,'remove(a) constrains pop to b by complete-candidate Theory')
end

-- 8 cyclic sibling support: tensor alone cannot attach; internal ring closes to joint occurrence.
do
  local function lane(name,inrole,outrole,control)
    local b=G.builder(); local m=b:membrane(nil,name); local x=b:point(m,'x'); local ins={b:strand(m,{inrole,x})}; local ctrl
    if control then ctrl=b:strand(m,{R.Control}); ins[#ins+1]=ctrl end
    local out=b:strand(m,{outrole,x}); b:face(m,ins,{out}); return b:finish(),ins[1],out,ctrl
  end
  local A,ai,ao,ctrl=lane('A',R.C,R.A,true); local B,bi,bo=lane('B',R.A,R.B); local C,ci,co=lane('C',R.B,R.C)
  local bb=G.builder(); local bm=bb:membrane(nil,'base'); bb:strand(bm,{R.Control}); local base=bb:finish(); eq(#cuts(base,tensor{A,B,C}),0)
  local ring=W.Algebra.close({A,B,C},{{ao,bi},{bo,ci},{co,ai}}); eq(#ring:faces(),1); eq(#cuts(base,ring),1)
end

-- 9 two pop siblings: Theory chooses the first two entries irrespective of source order.
do
  local base,map,keys=base_map({'a','b','c'},{{id='p1',role='ReqPop'},{id='p2',role='ReqPop'}}); local p1,m1=pop('p1'); local p2,m2=pop('p2'); local ranks={[keys.a]=1,[keys.b]=2,[keys.c]=3}; local function family(parts,metas)
    local proc,pimgs=W.Algebra.tensor(parts); local es={}; for i,meta in ipairs(metas) do es[i]=pimgs[i].strands[meta.entry] end; local good=0; for _,c in ipairs(cuts(base,proc)) do local ks={}; for i,e in ipairs(es) do ks[i]=ranks[G.points(c:strand(e))[3]] end; table.sort(ks); if ks[1]==1 and ks[2]==2 then good=good+1 end end; return good
  end
  eq(family({p1,p2},{m1,m2}),4,'two entry assignments x two unpinned request assignments'); eq(family({p2,p1},{m2,m1}),4)
end

-- 10 inserted lower-ranked key can participate only through together's internal cut.
do
  local base,map,keys=base_map({'a','b'},{{id='i',role='ReqPut',key='z'},{id='p',role='ReqPop'}}); local ip,im=put('i'); local pp,pm=pop('p'); eq(#cuts(base,tensor{ip,pp}),2,'tensor pop can only choose parent a/b'); local together,timgs=W.Algebra.close({ip,pp},{{im.entry,pm.entry}}); local cs=cuts(base,together); eq(#cs,1); local pkey=cs[1]:point(timgs[2].points[pm.key]); eq(pkey,keys.z,'internal cut carries exact inserted key into pop')
end

-- 11 exhaustive sibling permutations preserve 3! scarcity proofs.
local function perms(xs) local out={}; local function rec(a,i) if i>#a then local r={}; for j,v in ipairs(a) do r[j]=v end; out[#out+1]=r; return end; for j=i,#a do a[i],a[j]=a[j],a[i]; rec(a,i+1); a[i],a[j]=a[j],a[i] end end; rec(xs,1); return out end
do
  local base=base_counter(3,{{id='a',role='ReqTake'},{id='b',role='ReqTake'},{id='c',role='ReqTake'}}); local lanes={only(take('a')),only(take('b')),only(take('c'))}; for _,order in ipairs(perms(lanes)) do eq(#cuts(base,tensor(order)),36,'3! Unit assignments x 3! unpinned request assignments') end
end

-- 12 observation is over the complete candidate, not sibling scheduling order.
do
  local base=base_counter(5,{{id='t',role='ReqTake'},{id='o',role='ReqObserve'}}); local t=take('t')
  local ob=G.builder(); local om=ob:membrane(nil,'observe'); local call=ob:point(om,'o'); local c=ob:point(om,'counter'); local req=ob:strand(om,{R.ReqObserve,call,c}); local done=ob:strand(om,{R.DoneObserve,call,c}); ob:face(om,{req},{done}); local observe=ob:finish()
  for _,order in ipairs{{t,observe},{observe,t}} do local proc=tensor(order); local cs=cuts(base,proc); ok(#cs>0); for _,cut in ipairs(cs) do local after=select(1,W.Algebra.apply(base,proc,cut)); eq(count_role(after,R.Unit),4) end end
end
print('PASS external geometric_products',N,'assertions')
