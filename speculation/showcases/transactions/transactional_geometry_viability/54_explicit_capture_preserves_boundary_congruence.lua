local H=require('speculation.showcases.transactions.transactional_geometry_viability.common')
 local ok,eq,count=H.counter()
 local K=H.K

-- A one-hole wrapper with an independent captured outer Strand.  The child's
-- result and the captured Strand are merged explicitly after the hole.
local function capture_wrapper()
  local g={membranes={{parent=0}},points={},strands={},faces={}}
  for i=1,5 do g.points[i]={membrane=1}
 g.strands[i]={membrane=1,points={i}} end
  -- outer main -> child input
  g.faces[1]={membrane=1,inputs={1},outputs={3}}
  -- child output + captured outer authority -> outer result
  g.faces[2]={membrane=1,inputs={4,2},outputs={5}}
  return H.Context.normal({
    template={geometry=g,theory=K.spec(K.top({})),authority={inputs={1,2,4},outputs={3,5}},values={inputs={},outputs={}}},
    outer={authority={inputs={1,2},outputs={2}},values={inputs={},outputs={}}},
    holes={{target={definition='x'},authority={to_target={1},from_target={3}},values={to_target={},from_target={}}}}
  })
end

local step=assert(H.Context.plug(H.authority_step_context(),{}))
local diamond=assert(H.Context.plug(H.diamond_context(),{}))
eq(H.Case.key(step),H.Case.key(diamond),'control children are not boundary-equivalent')
local w=capture_wrapper()
local a=assert(H.Context.plug(w,{step}))
 local b=assert(H.Context.plug(w,{diamond}))
eq(H.Case.key(a),H.Case.key(b),'explicit captured-authority merge distinguished closed child history')
ok(H.A.complete(a) and H.A.complete(b),'capture wrapper lost complete exact authority boundary')
print('PASS gv 54: explicit captured authority cannot distinguish equal boundary Development cases ('..count()..')')
