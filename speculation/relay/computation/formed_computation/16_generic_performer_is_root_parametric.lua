local H=require('speculation.relay.computation.formed_computation.common')
local ok,eq,count=H.counter()

local a1=H.package('source_name_a',{H.value_context('a1'),H.value_context('a2')})
local a2=H.package('renamed_and_reordered',{H.value_context('a2'),H.value_context('a1')})
eq(a1:root('source_name_a'),a2:root('renamed_and_reordered'),
  'target semantic identity depended on source name or alternative order')
local b=H.package('b',{H.value_context('b1'),H.value_context('b2')})
ok(a1:root('source_name_a')~=b:root('b'),'unrelated target meanings collapsed to one root')

local run=H.roundtrip(H.C.perform_package(
  {authority={inputs=0,outputs=0},values={inputs=0,outputs=1}},nil,'run'))
local run_root=run:definitions()[1].root
local run_bytes=run:bytes()

local function execute(target,target_root,label)
  local form=H.roundtrip(H.C.form_package(target_root,0,'form_'..label))
  local linked=H.link({run,form,H.roundtrip(target)})
  local kind,result=H.C.perform(linked,form:definitions()[1].root,run_root)
  eq(kind,'Hit')
  eq(run:root('run'),nil,'decoded generic performer unexpectedly retained a source alias')
  eq(run:bytes(),run_bytes,'linking a target changed generic performer meaning')
  local seen={}
  for i=1,#result:family().items do seen[H.output_value(result,i,1)]=true end
  return seen
end

local sa=execute(a1,a1:root('source_name_a'),'a')
ok(sa.a1 and sa.a2,'generic performer did not admit all outcomes of target A')
local sb=execute(b,b:root('b'),'b')
ok(sb.b1 and sb.b2,'generic performer did not admit all outcomes of target B')
eq(run:definitions()[1].root,run_root,'generic performer root changed across target choices')
print('PASS tf 16: separately packaged perform is parametric over semantic target roots ('..count()..')')
