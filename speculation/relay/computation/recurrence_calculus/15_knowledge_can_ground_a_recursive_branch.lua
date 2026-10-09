local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
 local T,Context=H.T,H.Context
local base=Context.closed({geometry={membranes={},points={},strands={},faces={}},
  theory={variables={'x','y'},equalities={{a=T.var('x'),b=false},{a=T.var('y'),b='done'}}},
  authority={inputs={},outputs={}},values={inputs={'x'},outputs={'y'}}})
local step=Context.normal({template={geometry={membranes={},points={},strands={},faces={}},
  theory={variables={'x','ret','call','y'},equalities={{a=T.var('x'),b=true},
    {a=T.var('call'),b=false},{a=T.var('ret'),b=T.var('y')}}},authority={inputs={},outputs={}},
  values={inputs={'x','ret'},outputs={'call','y'}}},
  outer={authority={inputs={},outputs={}},values={inputs={1},outputs={2}}},
  holes={{target={definition='f'},authority={to_target={},from_target={}},
    values={to_target={1},from_target={2}}}}})
local p=H.rec_package('f',{base,step})
 local root=p:root('f')
local d1=H.Unfold.package(p,root,1)
 local d2=H.Unfold.package(p,root,2)
eq(#H.C.specialize(d1,{[1]=true}):family().items,0,'recursive branch completed before grounded descendant')
local yes=H.C.specialize(d2,{[1]=true})
 eq(#yes:family().items,1,'grounded recursive branch missing')
eq(H.T.value(yes:alternative(1).theory,yes:alternative(1).values.outputs[1]),'done')
eq(#H.C.specialize(d2,{[1]=false}):family().items,1,'base Theory branch missing')
print('PASS tr 15: positive knowledge grounds finite recursive descendants ('..count()..')')
