package.path='./src/?.lua;'..package.path
local W=require('worlds')
local Query=require('worlds.query')
local n=0
local function ok(x,m) n=n+1; assert(x,m) end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(q,budget) while true do local k,x=q:step(budget or math.huge); if k~='more' then return k,x end end end
local function token_world(count)
  local b=W.builder(); local m=b:membrane(nil,'root'); local p=b:point(m,'p'); local s={}; for i=1,count do s[i]=b:strand(m,{p},'s'..i) end; return b:finish(),s,p,m
end
local function pattern(count)
  local b=W.builder(); local m=b:membrane(nil,'p'); local x=b:point(m,'x'); local d={}; for i=1,count do d[i]=b:strand(m,{x},'d'..i) end; return b:finish(),d
end

-- Complete Question is exactly ordinary solve.
do
  local world,ss=token_world(2); local pat,d=pattern(2)
  local k,a=decided(W.solve(world,pat),100)
  local k2,b=decided(Query.solve(Query.complete(world,pat)),100)
  eq(k,'yes'); eq(k2,'yes'); eq(#a,#b); for i=1,#a do eq(a[i].from,b[i].from); eq(a[i].to,b[i].to) end
end

-- Source selection is an exact section of egress, not priority metadata.
do
  local world,ss=token_world(3); local pat,d=pattern(1)
  local q=Query.solve(Query.match(world,pat,{sources={ss[2]}})); local k,es=decided(q,10); eq(k,'yes'); eq(#es,1); eq(es[1].from,ss[2]); eq(es[1].to,d[1]); eq(decided(q,10),'done')
end

-- Target selection makes only that exact target part of the Question.
do
  local world,ss=token_world(1); local pat,d=pattern(2)
  local q=Query.solve(Query.match(world,pat,{targets={d[2]}})); local k,es=decided(q,10); eq(k,'yes'); eq(#es,1); eq(es[1].from,ss[1]); eq(es[1].to,d[2])
  local g,img=W.join({world,pat},es); ok(img[d[1]]~=ss[1]); eq(img[d[2]],ss[1])
end

-- Required is distinct from targets: optional targets may remain open.
do
  local world,ss=token_world(1); local pat,d=pattern(2)
  local q=Query.solve(Query.match(world,pat,{targets=d,required_targets={}})); local seen_empty,seen_one,hits=false,false,0
  while true do local k,es=decided(q,100); if k=='yes' then hits=hits+1; if #es==0 then seen_empty=true elseif #es==1 then seen_one=true end elseif k=='done' then break else error('unexpected '..tostring(k)) end end
  ok(seen_empty); ok(seen_one); eq(hits,3) -- empty, d1, d2
end

-- Admissibility is a finite exact relation, not a callback or kernel flag.
do
  local world,ss=token_world(2); local pat,d=pattern(2)
  local admissible={{from=ss[2],to=d[1]},{from=ss[1],to=d[2]}}
  local q=Query.solve(Query.match(world,pat,{admissible=admissible})); local k,es=decided(q,100); eq(k,'yes'); local by={}; for _,e in ipairs(es) do by[e.to]=e.from end; eq(by[d[1]],ss[2]); eq(by[d[2]],ss[1]); eq(decided(q,100),'done')
end

-- Section arrays denote sets: caller order cannot become priority.
do
  local world,ss=token_world(3); local pat,d=pattern(2)
  local function first(xs) local k,es=decided(Query.solve(Query.match(world,pat,{sources=xs})),100); eq(k,'yes'); return es end
  local a=first({ss[3],ss[1]}); local b=first({ss[1],ss[3]}); eq(#a,#b); for i=1,#a do eq(a[i].from,b[i].from); eq(a[i].to,b[i].to) end
end

-- Seeds must belong to the exact Question and to its admissibility relation.
do
  local world,ss=token_world(2); local pat,d=pattern(2)
  ok(not pcall(function() Query.match(world,pat,{sources={ss[1]},seeds={{from=ss[2],to=d[1]}}}) end))
  ok(not pcall(function() Query.match(world,pat,{targets={d[1]},seeds={{from=ss[1],to=d[2]}}}) end))
  ok(not pcall(function() Query.match(world,pat,{admissible={{from=ss[1],to=d[1]}},seeds={{from=ss[2],to=d[2]}}}) end))
end

-- An empty target section is the unit Question and yields one empty witness.
do
  local world=token_world(0); local pat,d=pattern(2)
  local q=Query.solve(Query.match(world,pat,{targets={}})); local k,es=decided(q,10); eq(k,'yes'); eq(#es,0); eq(decided(q,10),'done')
  local g,img=W.join({world,pat},es); ok(g:is_input(img[d[1]]) and g:is_input(img[d[2]]))
end

-- The sacred solve façade rejects query policy instead of silently absorbing it.
do
  local world,ss=token_world(1); local pat=pattern(1)
  ok(not pcall(function() W.solve(world,pat,{sources={ss[1]}}) end),'W.solve must not accept Question policy')
end



-- Matching is a real judgement, not merely "join accepts these equations".
-- An unrooted causal fragment may be quotiented by join, but is not an
-- executable development for matching.
do
  local wb=W.builder(); local wm=wb:membrane(nil,'world'); local s=wb:strand(wm,{},'s'); local world=wb:finish()
  local pb=W.builder(); local pm=pb:membrane(nil,'pattern'); local d=pb:strand(pm,{},'d'); local spontaneous=pb:strand(pm,{},'spontaneous'); pb:face(pm,{}, {spontaneous},'unrooted'); local pat=pb:finish()
  local joined=pcall(function() return W.join({world,pat},{{from=s,to=d}}) end); ok(joined,'join should accept the lawful quotient')
  local q=Query.match(world,pat,{seeds={{from=s,to=d}}})
  ok(not pcall(function() Query.solve(q) end),'matching must reject a target with an unrooted causal fragment')
end

-- A constructive yes(E) must be immediately consumable by strict join.  This
-- regression is the locality-lifetime counterexample which previously allowed
-- Question to say yes while the resulting quotient violated Geometry law 8.
do
  local function depth(m) local n=0 while m do n=n+1; m=W.parent(m) end return n end
  local function provider(levels)
    local b=W.builder(); local m=nil; for i=1,levels do m=b:membrane(m,'provider.'..i) end
    local input=b:strand(m,{},'provider.in'); local output=b:strand(m,{},'provider.out'); b:face(m,{input},{output},'provider.work')
    return b:finish(),input,output
  end
  local function excursion(threaded)
    local b=W.builder(); local root=b:membrane(nil,'root'); local outer=b:membrane(root,'outer'); local inner=b:membrane(root,'inner'); local target=b:membrane(outer,'target')
    local start=b:strand(outer,{},'start'); local work=b:strand(inner,{},'work'); local cap=threaded and b:strand(outer,{},'outer.cap') or nil
    local outs={work}; if cap then outs[#outs+1]=cap end; b:face(root,{start},outs,'depart')
    local returned=b:strand(target,{},'returned'); local carry=b:strand(target,{},'carry'); local locality=b:strand(target,{},'locality'); b:face(target,{returned},{carry,locality},'open')
    local accept=b:strand(target,{},'accept'); local ins={work,locality}; if cap then ins[#ins+1]=cap end; b:face(root,ins,{accept},'return')
    return b:finish(),{target=target,accept=accept,returned=returned}
  end
  local function question_for(threaded)
    local context,x=excursion(threaded); local provider_g,pin,pout=provider(depth(x.target)); local product,image=W.join({context,provider_g},{})
    local accept,returned=image[x.accept],image[x.returned]; pin,pout=image[pin],image[pout]
    local admissible={{from=accept,to=pin},{from=pout,to=returned}}
    local question=Query.match(product,product,{sources={accept,pout},targets={pin,returned},required_targets={pin,returned},admissible=admissible})
    return product,question
  end

  local bad,badq=question_for(false); local bk,bv=decided(Query.solve(badq),math.huge)
  eq(bk,'no','Question must refute a candidate whose quotient violates Geometry locality law')
  ok(Query.is_refutation(bv)); eq(bv:reason().kind,'unlawful-realisation'); ok(type(bv:reason().reason)=='string')

  local good,goodq=question_for(true); local gk,es=decided(Query.solve(goodq),math.huge)
  eq(gk,'yes'); eq(#es,2); local closed=W.join({good},es); ok(W.is_geometry(closed),'every Question yes witness must be consumable by strict join')
end

-- Exhaustive absence is positive evidence about one exact finite Question.  It
-- does not become false merely because a later, different Question may Hit.
do
  local b=W.builder(); local m=b:membrane(); local a=b:point(m); local world=b:finish()
  local p=W.builder(); local pm=p:membrane(); local d=p:strand(pm,{a}); local target=p:finish()
  local question=Query.complete(world,target,{})
  local solve=Query.solve(question); local tag,no=solve:step(math.huge)
  eq(tag,'no'); ok(Query.is_refutation(no)); eq(no:question(),question); eq(no:source(),W.boundary(world)); eq(no:target(),target); ok(type(no:reason().kind)=='string')
end


-- Question inputs and accessors are deeply immutable at the finite-relation
-- boundary. Caller mutation cannot alter a retained Question/Refutation.
do
  local world,ss=token_world(2); local pat,d=pattern(2)
  local seed={from=ss[1],to=d[1]}; local admissible={{from=ss[1],to=d[1]},{from=ss[2],to=d[2]}}
  local question=Query.match(world,pat,{seeds={seed},admissible=admissible})
  seed.from=ss[2]; admissible[1].from=ss[2]
  local seeds=question:seeds(); eq(seeds[1].from,ss[1]); eq(seeds[1].to,d[1])
  seeds[1].from=ss[2]; eq(question:seeds()[1].from,ss[1])
  local allowed=question:admissible(); allowed[1].from=ss[2]
  local allowed2=question:admissible(); ok((allowed2[1].from==ss[1] and allowed2[1].to==d[1]) or (allowed2[2].from==ss[1] and allowed2[2].to==d[1]))
  local k,es=decided(Query.solve(question),100); eq(k,'yes'); local by={}; for _,e in ipairs(es) do by[e.to]=e.from end; eq(by[d[1]],ss[1]); eq(by[d[2]],ss[2])
end

-- Seed equations are a finite injective set, not ordered mutable hints.
do
  local world,ss=token_world(2); local pat,d=pattern(2)
  ok(not pcall(function() Query.match(world,pat,{seeds={{from=ss[1],to=d[1]},{from=ss[1],to=d[1]}}}) end))
  ok(not pcall(function() Query.match(world,pat,{seeds={{from=ss[1],to=d[1]},{from=ss[1],to=d[2]}}}) end))
  ok(not pcall(function() Query.match(world,pat,{seeds={{from=ss[1],to=d[1]},{from=ss[2],to=d[1]}}}) end))
  local q1=Query.match(world,pat,{seeds={{from=ss[2],to=d[2]},{from=ss[1],to=d[1]}}})
  local q2=Query.match(world,pat,{seeds={{from=ss[1],to=d[1]},{from=ss[2],to=d[2]}}})
  local a,b=q1:seeds(),q2:seeds(); eq(#a,#b); for i=1,#a do eq(a[i].from,b[i].from); eq(a[i].to,b[i].to) end
end


-- The Question specification is closed.  A misspelt restrictive field must
-- fail rather than silently widening the Question to a complete section.
do
  local world,ss=token_world(2); local pat,d=pattern(1)
  ok(not pcall(function() Query.match(world,pat,{soruces={ss[1]}}) end),'unknown Question fields must be rejected')
  ok(not pcall(function() Query.match(world,pat,{sources={[2]=ss[1]}}) end),'sparse source sections must be rejected')
  ok(not pcall(function() Query.match(world,pat,{targets={[2]=d[1]}}) end),'sparse target sections must be rejected')
  ok(not pcall(function() Query.match(world,pat,{required_targets={[2]=d[1]}}) end),'sparse required sections must be rejected')
  ok(not pcall(function() Query.match(world,pat,{admissible={[2]={from=ss[1],to=d[1]}}}) end),'sparse admissibility must be rejected')
  ok(not pcall(function() Query.match(world,pat,{seeds={[2]={from=ss[1],to=d[1]}}}) end),'sparse seeds must be rejected')
end

-- Type predicates recognise closure-owned values, not spoofable protected
-- metatable labels.
do
  local fake_q=setmetatable({}, {__metatable='Worlds Question'})
  local fake_r=setmetatable({}, {__metatable='Worlds Refutation'})
  ok(not Query.is_question(fake_q),'Question predicate must not trust metatable labels')
  ok(not Query.is_refutation(fake_r),'Refutation predicate must not trust metatable labels')
end

print('PASS query',n,'assertions')
