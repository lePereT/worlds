local H=require('speculation.showcases.transactions.transactional_recurrence_calculus.common')
local ok,eq,count=H.counter()
 local Context=H.Context
local g={membranes={{parent=0}},points={},strands={},faces={}}
for i=1,6 do g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}} end
g.faces={{membrane=1,inputs={1},outputs={3}},{membrane=1,inputs={2},outputs={4}}}
local pair=Context.normal({template={geometry=g,theory={variables={},equalities={}},
  authority={inputs={1,2,5,6},outputs={3,4,5,6}},values={inputs={},outputs={}}},
  outer={authority={inputs={1,2},outputs={3,4}},values={inputs={},outputs={}}},holes={
    {target={definition='loop'},authority={to_target={1},from_target={3}},values={to_target={},from_target={}}},
    {target={definition='loop'},authority={to_target={2},from_target={4}},values={to_target={},from_target={}}},
  }})
local p=H.RP.new({definitions={
  {identity='loop',alternatives={H.authority_identity_context(),H.unary_context({definition='loop'})}},
  {identity='pair',alternatives={pair}},
}})
local f=H.Unfold.package(p,p:root('pair'),4)
eq(#f:family().items,9,'two recursive siblings did not form Cartesian finite meanings')
local found=false
for _,a in ipairs(f:family().items) do
  if #a.geometry.faces>=4 then
    local n=#a.geometry.faces
    local comparable=false
    for i=1,n do for j=i+1,n do
      if H.C.Geometry().face_reaches(a.geometry,i,j) or H.C.Geometry().face_reaches(a.geometry,j,i) then
        -- Some pairs are within a branch; we need at least one incomparable pair.
      else comparable=true end
    end end
    if comparable then found=true break end
  end
end
ok(found,'positive recursive siblings were globally serialised')
print('PASS tr 28: independent recursive children remain positive concurrency ('..count()..')')
