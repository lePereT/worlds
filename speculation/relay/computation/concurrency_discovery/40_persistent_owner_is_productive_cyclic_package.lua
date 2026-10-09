local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local R=H.RecurrentOwner
local p=R.package()
ok(p:root('empty')~=p:root('full'),'Empty and Full recurrent roots collapsed')
local bytes=p:bytes()
local u2=R.unfold(p,'empty',2)
local u5=R.unfold(p,'empty',5)
ok(#u2:family().items>0,'productive recurrent owner had empty finite prefix meaning')
ok(#u5:family().items>#u2:family().items,'deeper owner observation did not expose more finite prefixes')
eq(p:bytes(),bytes,'observing recurrent owner changed cyclic Package meaning')
local saw_full=false
for _,a in ipairs(u5:family().items) do
  local ins=a.support and a.support.strands and a.support.strands[a.authority.inputs[1]]
  local outs=a.support and a.support.strands and a.support.strands[a.authority.outputs[1]]
  eq(ins and ins.state,'empty','recursive plug lost grounded source-state support')
  if outs and outs.state=='full' then saw_full=true end
end
ok(saw_full,'productive owner never exposed a Full finite prefix')
ok(H.no_runtime_words(bytes))
print('PASS cc 40: persistent ownership is finite productive cyclic Package topology ('..count()..')')
