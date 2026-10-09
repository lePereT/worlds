local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local depth=8
local base=H.package('base',{H.value_context('done')})
local packages={base}
local root=base:root('base')
local layer_roots={root}

-- Each layer is ordinary Package meaning whose result is a formed value denoting
-- the previous layer. The final outer form adds the last introduction layer.
for i=2,depth do
  local p=H.package('layer'..i,{H.C.form_context(root,0)})
  packages[#packages+1]=p
  root=p:root('layer'..i)
  layer_roots[i]=root
end
local outer=H.C.form_package(root,0,'outer')
local performer=H.C.perform_package({authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run')
packages[#packages+1]=outer
packages[#packages+1]=performer
local linked=H.link(packages)
local pr=performer:root('run')
local pc=performer:definition(pr).family.items[1]

local kind,current=H.C.perform(linked,outer:root('outer'),pr)
eq(kind,'Hit')
for remaining=depth-1,1,-1 do
  eq(H.output_value(current),layer_roots[remaining],
    'one perform removed more or less than one form layer at depth '..tostring(remaining+1))
  local next_kind,next_value=H.C.perform_family(linked,
    H.Family.new(current:family().items,current:family().edges),pc)
  eq(next_kind,'Hit')
  current=next_value
end
eq(H.output_value(current),'done','finite nesting did not reach the base only after explicit elimination')
ok(not current:bytes():find('perform',1,true) and not current:bytes():find('form',1,true),
  'finite nesting left evaluator/form residue')
print('PASS tf 14: arbitrary finite nesting is structural; one perform removes one layer ('..count()..')')
