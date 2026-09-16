-- Worlds 0.6.1 investigation: can Relay Front collapse holes/offers/scalars
-- into open Geometry plus transient finite cuts?
--
-- A cut in this file is deliberately NOT a Worlds carrier. It is a Lua view
-- containing references to existing open Strand occurrences. The only semantic
-- operations are Worlds Question, join, boundary and advance.

local W=require('worlds')
local Q=require('worlds.query')

local checks=0
local function ok(x,msg) checks=checks+1; assert(x,msg) end
local function eq(a,b,msg) checks=checks+1; assert(a==b,(msg or 'not equal')..': '..tostring(a)..' ~= '..tostring(b)) end
local function decided(question)
    local engine=Q.solve(question)
    local tag,value=engine:step(math.huge)
    assert(tag=='yes' or tag=='no','unbounded Question must decide: '..tostring(tag))
    return tag,value
end
local function named(xs,name)
    for _,x in ipairs(xs) do if W.name(x)==name then return x end end
end
local function point_named(g,name) return named(g:points(),name) end
local function strand_named(g,name) return named(g:strands(),name) end
local function egress_named(g,name) return named(g:egress(),name) end

-- External rigid protocol/evidence roles.
local rb=W.builder(); local rm=rb:membrane(nil,'roles')
local REQUEST=rb:point(rm,'REQUEST'); local DONE=rb:point(rm,'DONE')
local CONTROL=rb:point(rm,'CONTROL'); local VALUE=rb:point(rm,'VALUE')
local AUTH=rb:point(rm,'AUTH'); local SIDE=rb:point(rm,'SIDE')
rb=rb:finish()

local function counts(g) return #g:membranes(),#g:points(),#g:strands(),#g:faces() end
local function cut(ingress,egress)
    -- A compiler view only: no builder, no Geometry mutation, no semantic tag.
    return {ingress=ingress or {},egress=egress or {}}
end
local function append(dst,xs) for _,x in ipairs(xs or {}) do dst[#dst+1]=x end end

-- Compose arbitrary selected cuts by a direct finite-closure Question over the
-- original disjoint Geometry parts. No staging product is constructed: the
-- Question ranges over exactly the parts that strict join will later consume.
local function close_cuts(parts,cuts,edges,required)
    local sources,targets={},{}
    for _,c in ipairs(cuts) do append(sources,c.egress); append(targets,c.ingress) end
    local admissible={}
    for _,e in ipairs(edges or {}) do admissible[#admissible+1]={from=e.from,to=e.to} end
    local req={}
    if required then append(req,required) else append(req,targets) end
    local q=Q.close(parts,{sources=sources,targets=targets,required_targets=req,admissible=admissible})
    local tag,evidence=decided(q)
    if tag=='no' then return tag,nil,evidence end
    local composite,cimage=W.join(parts,evidence)
    return 'yes',composite,evidence,nil,nil,nil,cimage
end

-- ---------------------------------------------------------------------------
-- C1. Selecting a cut creates no semantic carrier. It is literally a view onto
-- existing ingress/egress occurrences.
do
    local b=W.builder(); local m=b:membrane(nil,'g'); local i=b:strand(m,{},'i'); local o=b:strand(m,{},'o'); b:face(m,{i},{o},'f'); local g=b:finish()
    local a,bp,c,d=counts(g); local x=cut({i},{o}); local a2,b2,c2,d2=counts(g)
    eq(a,a2); eq(bp,b2); eq(c,c2); eq(d,d2); ok(x.ingress[1]==i and x.egress[1]==o,'cut must refer to literal existing carriers')
end

-- ---------------------------------------------------------------------------
-- C2. A presentation-sized value uses the same cut closer as any other opening.
-- No scalar route is required.
local function value_producer(role,name)
    local b=W.builder(); local m=b:membrane(nil,name..'.root'); local start=b:strand(m,{},name..'.start'); local p=b:point(m,name..'.value'); local out=b:strand(m,{role,p},name..'.value.out'); b:face(m,{start},{out},name..'.produce')
    return b:finish(),cut({}, {out}),p,start,out
end
local function value_consumer(role,name)
    local b=W.builder(); local m=b:membrane(nil,name..'.root'); local p=b:point(m,name..'.value'); local input=b:strand(m,{role,p},name..'.value.in'); local done=b:strand(m,{p},name..'.done'); b:face(m,{input},{done},name..'.consume')
    return b:finish(),cut({input},{}),p,input,done
end

do
    local a,ac,ap,_,ao=value_producer(VALUE,'producer')
    local b,bc,bp,bi=value_consumer(VALUE,'consumer')
    local tag,g,_,product,image,_,cimage=close_cuts({a,b},{ac,bc},{{from=ao,to=bi}})
    eq(tag,'yes','one-way presentation cut must close generically')
    local live=W.boundary(g); eq(#live:egress(),1); local done=live:egress()[1]
    local final_ap=cimage[ap]; local final_bp=cimage[bp]
    ok(W.points(done)[1]==final_ap,'target-local scalar denotation must instantiate to producer Point image')
    ok(final_ap==final_bp,'producer and consumer local denotations must quotient to one exact Point')
end

-- ---------------------------------------------------------------------------
-- C3. The existing direct scalar-callable shape is itself an ordinary Development.
-- Matching/advance instantiates local operation/parameter Points; the result is
-- exact source identity. No scalar semantic carrier is needed.
local function scalar_second()
    local b=W.builder(); local m=b:membrane(nil,'second'); local op=b:point(m,'op'); local x=b:point(m,'x'); local y=b:point(m,'y')
    local request=b:strand(m,{REQUEST,op,x,y},'request'); local done=b:strand(m,{DONE,op,y},'done'); b:face(m,{request},{done},'body')
    return b:finish(),{op=op,x=x,y=y,request=request,done=done}
end
local function scalar_call_world()
    local b=W.builder(); local m=b:membrane(nil,'caller'); local op=b:point(m,'caller.op'); local x=b:point(m,'caller.x'); local y=b:point(m,'caller.y'); local req=b:strand(m,{REQUEST,op,x,y},'request.ready')
    return b:finish(),{op=op,x=x,y=y,request=req}
end

do
    local world,w=scalar_call_world(); local second=scalar_second(); local q=Q.complete(world,second,{})
    local tag,hit=decided(q); eq(tag,'yes','direct scalar callable must be just an executable open Development')
    local live=W.advance(world,second,hit); eq(#live:egress(),1)
    local ps=W.points(live:egress()[1]); eq(ps[1],DONE); ok(ps[2]==w.op,'operation identity should instantiate from caller'); ok(ps[3]==w.y,'second result should literally be caller y identity')
    ok(not live:owns_point(w.x),'unused scalar x identity should disappear from future boundary')
end

-- ---------------------------------------------------------------------------
-- C4. A bidirectional open-computation protocol is closed by the SAME helper.
-- The only difference from C2 is cut shape: both sides expose ingress+egress.
local function context_side()
    local b=W.builder(); local m=b:membrane(nil,'context'); local meaning=b:point(m,'ctx.meaning')
    local start=b:strand(m,{meaning},'ctx.start'); local request=b:strand(m,{CONTROL,meaning},'ctx.request'); b:face(m,{start},{request},'ctx.send')
    local response=b:strand(m,{CONTROL,meaning},'ctx.response'); local done=b:strand(m,{meaning},'ctx.done'); b:face(m,{response},{done},'ctx.receive')
    return b:finish(),cut({response},{request}),{meaning=meaning,request=request,response=response,done=done}
end
local function offered_side()
    local b=W.builder(); local m=b:membrane(nil,'offered'); local meaning=b:point(m,'offered.meaning')
    local request=b:strand(m,{CONTROL,meaning},'offered.request'); local response=b:strand(m,{CONTROL,meaning},'offered.response'); b:face(m,{request},{response},'offered.work')
    return b:finish(),cut({request},{response}),{meaning=meaning,request=request,response=response}
end

do
    local a,ac,ax=context_side(); local b,bc,bx=offered_side()
    local tag,g=close_cuts({a,b},{ac,bc},{
        {from=ax.request,to=bx.request}, {from=bx.response,to=ax.response},
    })
    eq(tag,'yes','bidirectional computation cut must use the same generic closure')
    local live=W.boundary(g); eq(#live:egress(),1); local ps=W.points(live:egress()[1]); ok(ps[1]==ax.meaning,'offered local meaning must quotient to the context meaning')
end

-- ---------------------------------------------------------------------------
-- C5. Cuts can be mixed: control and ordinary value denotation are simply Point
-- incidence on the same selected Strand. There is no scalar/context boundary.
local function mixed_context()
    local b=W.builder(); local m=b:membrane(nil,'mixed.context'); local v=b:point(m,'value'); local start=b:strand(m,{},'start'); local req=b:strand(m,{CONTROL,v},'request'); b:face(m,{start},{req},'send'); return b:finish(),cut({}, {req}),{v=v,req=req}
end
local function mixed_consumer()
    local b=W.builder(); local m=b:membrane(nil,'mixed.consumer'); local v=b:point(m,'value'); local req=b:strand(m,{CONTROL,v},'request'); local out=b:strand(m,{v},'result'); b:face(m,{req},{out},'consume'); return b:finish(),cut({req},{}),{v=v,req=req,out=out}
end

do
    local a,ac,ax=mixed_context(); local b,bc,bx=mixed_consumer(); local tag,g=close_cuts({a,b},{ac,bc},{{from=ax.req,to=bx.req}}); eq(tag,'yes')
    local result=W.boundary(g):egress()[1]; ok(W.points(result)[1]==ax.v,'value identity should cross a computation-shaped cut without a scalar route')
end

-- ---------------------------------------------------------------------------
-- C6. A cut may select only part of a larger boundary. Unselected open incidence
-- remains open after composition by Worlds law 32.
do
    local b=W.builder(); local m=b:membrane(nil,'producer'); local v=b:point(m,'v'); local chosen=b:strand(m,{v},'chosen'); local side=b:strand(m,{SIDE},'side'); local a=b:finish(); local ac=cut({}, {chosen})
    local c=W.builder(); local cm=c:membrane(nil,'consumer'); local x=c:point(cm,'x'); local need=c:strand(cm,{x},'need'); local other=c:strand(cm,{SIDE},'other.need'); local out=c:strand(cm,{x},'out'); c:face(cm,{need},{out},'use'); local d=c:finish(); local dc=cut({need},{})
    local tag,g=close_cuts({a,d},{ac,dc},{{from=chosen,to=need}}); eq(tag,'yes')
    local bg=W.boundary(g); ok(egress_named(bg,'side')~=nil,'unselected producer boundary must remain open'); ok(named(bg:ingress(),'other.need')~=nil,'unselected consumer ingress must remain open')
end

-- ---------------------------------------------------------------------------
-- C7. The generic cut Question still obeys exact scarcity: one exact occurrence
-- cannot satisfy two requirements merely because both are selected through cuts.
do
    local b=W.builder(); local m=b:membrane(nil,'one'); local s=b:strand(m,{},'one'); local src=b:finish(); local sc=cut({}, {s})
    local c=W.builder(); local cm=c:membrane(nil,'two'); local a=c:strand(cm,{},'a'); local z=c:strand(cm,{},'b'); local dst=c:finish(); local dc=cut({a,z},{})
    local tag=close_cuts({src,dst},{sc,dc},{{from=s,to=a},{from=s,to=z}}); eq(tag,'no','cut abstraction must not weaken Worlds scarcity')
end

-- ---------------------------------------------------------------------------
-- C8. Locality is still intrinsic to the selected carriers. A cut adds no depth
-- metadata: matching the selected occurrences simply inherits Worlds ancestry law.
local function local_value(depth,label)
    local b=W.builder(); local m=nil; for i=1,depth do m=b:membrane(m,label..'.'..i) end; local s=b:strand(m,{VALUE},label..'.s'); return b:finish(),cut({}, {s}),s
end
local function local_need(depth,label)
    local b=W.builder(); local m=nil; for i=1,depth do m=b:membrane(m,label..'.'..i) end; local s=b:strand(m,{VALUE},label..'.s'); return b:finish(),cut({s},{}),s
end

do
    local a,ac,as=local_value(1,'shallow'); local b,bc,bi=local_need(2,'deep')
    eq(close_cuts({a,b},{ac,bc},{{from=as,to=bi}}),'no','cut must not bypass Level ancestry')
    local c,cc,cs=local_value(2,'deep.source'); local d,dc,di=local_need(2,'deep.target')
    eq(close_cuts({c,d},{cc,dc},{{from=cs,to=di}}),'yes')
end

-- ---------------------------------------------------------------------------
-- C9. Direction is not a property of a cut object. The same cut record shape is
-- used on both sides; polarity follows solely from selected ingress/egress and
-- admissible equations.
do
    local a,ac,ax=context_side(); local b,bc,bx=offered_side()
    eq(#ac.ingress,#bc.ingress); eq(#ac.egress,#bc.egress)
    local tag,g=close_cuts({b,a},{bc,ac},{
        {from=bx.response,to=ax.response}, {from=ax.request,to=bx.request},
    })
    eq(tag,'yes','swapping frame/order must not require Hole versus Offer cut types')
    eq(#W.boundary(g):egress(),1)
end

-- ---------------------------------------------------------------------------
-- C10. Simultaneous finite cuts can connect several presentations in one exact
-- Question; there is no need to repeatedly invoke a scalar or hole-specific route.
do
    local p1,c1,_,_,o1=value_producer(VALUE,'p1'); local p2,c2,_,_,o2=value_producer(SIDE,'p2')
    local q1,d1,_,i1=value_consumer(VALUE,'q1'); local q2,d2,_,i2=value_consumer(SIDE,'q2')
    local tag,g=close_cuts({p1,p2,q1,q2},{c1,c2,d1,d2},{{from=o1,to=i1},{from=o2,to=i2}}); eq(tag,'yes')
    eq(#W.boundary(g):egress(),2,'both independently presented results should survive one simultaneous closure')
end

-- ---------------------------------------------------------------------------
-- C11. Bidirectional closure may create mutual causal support. Generic cut
-- composition must therefore inherit join SCC normalisation, not special-case it.
local function half_cycle(label,role_out,role_in)
    local b=W.builder(); local m=b:membrane(nil,label); local input=b:strand(m,{role_in},label..'.in'); local output=b:strand(m,{role_out},label..'.out'); local f=b:face(m,{input},{output},label..'.face'); return b:finish(),cut({input},{output}),{input=input,output=output,face=f}
end

do
    local a,ac,ax=half_cycle('a',VALUE,SIDE); local b,bc,bx=half_cycle('b',SIDE,VALUE)
    local tag,g,eqs,product,image,mapped,cimage=close_cuts({a,b},{ac,bc},{{from=ax.output,to=bx.input},{from=bx.output,to=ax.input}})
    eq(tag,'yes'); eq(#g:faces(),1,'generic bidirectional cut must inherit Worlds SCC normalisation'); eq(#g:strands(),0,'closed mutual-support seam should have no residual Strand')
    ok(cimage[ax.face]==cimage[bx.face],'both cyclic Faces must map to one joint Face')
end


-- ---------------------------------------------------------------------------
-- C12. Authority does not make a new cut species. Selecting only control gives
-- Portal-like behaviour (authority remains open); selecting control+authority
-- gives Handoff-like behaviour (authority is consumed and a fresh occurrence is
-- returned by the target Development).
local function transfer_source()
    local b=W.builder(); local m=b:membrane(nil,'transfer.source'); local control=b:strand(m,{CONTROL},'control'); local auth=b:strand(m,{AUTH},'authority')
    return b:finish(),{control=cut({}, {control}),authority=cut({}, {auth})},{control=control,auth=auth}
end
local function portal_target()
    local b=W.builder(); local m=b:membrane(nil,'portal.target'); local control=b:strand(m,{CONTROL},'control.in'); local done=b:strand(m,{},'done'); b:face(m,{control},{done},'portal.work')
    return b:finish(),cut({control},{}),{control=control,done=done}
end
local function handoff_target()
    local b=W.builder(); local root=b:membrane(nil,'handoff.target'); local dest=b:membrane(root,'destination')
    local control=b:strand(root,{CONTROL},'control.in'); local auth=b:strand(root,{AUTH},'authority.in'); local done=b:strand(dest,{},'done'); local moved=b:strand(dest,{AUTH},'authority.out')
    b:face(root,{control,auth},{done,moved},'handoff.work')
    return b:finish(),{control=cut({control},{}),authority=cut({auth},{})},{control=control,auth=auth,moved=moved}
end

do
    local src,cuts,x=transfer_source(); local portal,pc,px=portal_target()
    local tag,g=close_cuts({src,portal},{cuts.control,pc},{{from=x.control,to=px.control}}); eq(tag,'yes')
    local live=W.boundary(g); ok(live:owns_strand(x.auth),'unselected exact authority should remain literally open')

    local src2,cuts2,y=transfer_source(); local hand,hc,hx=handoff_target()
    local tag2,g2=close_cuts({src2,hand},{cuts2.control,cuts2.authority,hc.control,hc.authority},{
        {from=y.control,to=hx.control},{from=y.auth,to=hx.auth},
    }); eq(tag2,'yes')
    local live2=W.boundary(g2); ok(not live2:owns_strand(y.auth),'selected authority cut must consume caller occurrence')
    local moved=egress_named(live2,'authority.out'); ok(moved~=nil and W.points(moved)[1]==AUTH,'target may expose fresh authority through ordinary Geometry')
end

-- ---------------------------------------------------------------------------
-- C13. One Development may expose several protocol/presentation cuts at once.
-- There is therefore no intrinsic Development kind = scalar/context.
local function hybrid_source()
    local b=W.builder(); local m=b:membrane(nil,'hybrid'); local v=b:point(m,'v'); local start=b:strand(m,{},'start')
    local scalar=b:strand(m,{VALUE,v},'scalar.out'); local control=b:strand(m,{CONTROL},'control.out'); b:face(m,{start},{scalar,control},'produce.both')
    return b:finish(),{scalar=cut({}, {scalar}),control=cut({}, {control})},{scalar=scalar,control=control,v=v}
end
local function control_consumer()
    local b=W.builder(); local m=b:membrane(nil,'control.consumer'); local i=b:strand(m,{CONTROL},'control.in'); local o=b:strand(m,{},'control.done'); b:face(m,{i},{o},'use.control')
    return b:finish(),cut({i},{}),i
end

do
    local src,cuts,x=hybrid_source(); local vc,vc_cut,_,vi=value_consumer(VALUE,'value.consumer'); local cc,cc_cut,ci=control_consumer()
    local tag,g=close_cuts({src,vc},{cuts.scalar,vc_cut},{{from=x.scalar,to=vi}}); eq(tag,'yes')
    ok(egress_named(W.boundary(g),'control.out')~=nil,'using scalar presentation must leave unrelated control opening intact')

    local src2,cuts2,y=hybrid_source(); local vc2,vcut2,_,vi2=value_consumer(VALUE,'value.consumer2'); local cc2,ccut2,ci2=control_consumer()
    local tag2,g2=close_cuts({src2,vc2,cc2},{cuts2.scalar,cuts2.control,vcut2,ccut2},{
        {from=y.scalar,to=vi2},{from=y.control,to=ci2},
    }); eq(tag2,'yes'); eq(#W.boundary(g2):egress(),2,'one hybrid Development should satisfy both presentation kinds simultaneously')
end

-- ---------------------------------------------------------------------------
-- C14. Cut compatibility is simply Worlds incidence compatibility. Rigid role
-- mismatch and arity mismatch are exact negative judgements, not type tags on a cut.
do
    local b=W.builder(); local m=b:membrane(nil,'src'); local s=b:strand(m,{VALUE},'s'); local src=b:finish(); local sc=cut({}, {s})
    local c=W.builder(); local cm=c:membrane(nil,'wrong.role'); local t=c:strand(cm,{SIDE},'t'); local dst=c:finish(); local dc=cut({t},{})
    eq(close_cuts({src,dst},{sc,dc},{{from=s,to=t}}),'no','rigid role mismatch must refute cut closure')

    local d=W.builder(); local dm=d:membrane(nil,'wrong.arity'); local u=d:strand(dm,{VALUE,SIDE},'u'); local dst2=d:finish(); local dc2=cut({u},{})
    eq(close_cuts({src,dst2},{sc,dc2},{{from=s,to=u}}),'no','incidence arity mismatch must refute cut closure')
end

-- ---------------------------------------------------------------------------
-- C15. Finite Questions already express residual/partial closure: selected
-- targets need not all be required. This is the judgemental basis of partial
-- application; residual open boundary remains ordinary Geometry.
do
    local p=W.builder(); local pm=p:membrane(nil,'partial.source'); local a=p:strand(pm,{VALUE},'a'); local b=p:strand(pm,{SIDE},'b'); local src=p:finish()
    local t=W.builder(); local tm=t:membrane(nil,'partial.target'); local x=t:strand(tm,{VALUE},'x'); local y=t:strand(tm,{SIDE},'y'); local dst=t:finish()
    local question=Q.close({src,dst},{
        sources={a,b}, targets={x,y}, required_targets={x},
        admissible={{from=a,to=x},{from=b,to=y}},
    })
    local tag,es=decided(question); eq(tag,'yes'); eq(#es,1,'first exact witness should close only the required target')
    eq(es[1].from,a); eq(es[1].to,x)
end

-- ---------------------------------------------------------------------------
-- C16. A cut is not a persisted semantic label. Once selected occurrences are
-- joined and boundary-projected, only surviving carriers remain; the same live
-- Geometry can be selected again under a completely different compiler view.
do
    local a,ac,_,_,ao=value_producer(VALUE,'reselect.producer'); local b,bc,_,bi=value_consumer(VALUE,'reselect.consumer')
    local tag,g=close_cuts({a,b},{ac,bc},{{from=ao,to=bi}}); eq(tag,'yes')
    local live=W.boundary(g); local out=assert(live:egress()[1]); local before={counts(live)}
    local again=cut({}, {out}); local after={counts(live)}
    for i=1,4 do eq(before[i],after[i]) end; ok(again.egress[1]==out,'a later cut is merely a new view over the exact surviving boundary')
end

print('PASS Relay direct-close cut/scalar Worlds toy',checks,'assertions')
