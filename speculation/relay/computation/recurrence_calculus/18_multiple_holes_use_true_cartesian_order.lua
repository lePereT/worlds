local H=require('speculation.relay.computation.recurrence_calculus.common')
local ok,eq,count=H.counter()
local p=H.RP.new({definitions={
  {identity='a',alternatives={H.closed_chain_context(0),H.closed_chain_context(1)},prefers={{1,2}}},
  {identity='b',alternatives={H.closed_chain_context(0),H.closed_chain_context(2)},prefers={{1,2}}},
  {identity='pair',alternatives={H.zero_hole_context({{definition='a'},{definition='b'}})}},
}})
local f=H.Unfold.package(p,p:root('pair'),2):family()
 eq(#f.items,4)
local by={}
 for i,a in ipairs(f.items) do by[#a.geometry.faces]=i end
ok(H.reach(f,by[0],by[1]))
 ok(H.reach(f,by[0],by[2]))
 ok(H.reach(f,by[1],by[3]))
 ok(H.reach(f,by[2],by[3]))
ok(not H.reach(f,by[1],by[2]) and not H.reach(f,by[2],by[1]),'recursive hole product became lexicographic')
print('PASS tr 18: multiple recursive holes lift preference by Cartesian product ('..count()..')')
