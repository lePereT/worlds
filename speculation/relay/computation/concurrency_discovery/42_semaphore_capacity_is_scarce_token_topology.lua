local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local C,S=H.C,H.Semaphore
local two=S.seed('gate',2)
local one=C.together({two,S.acquire('gate')})
ok(#one:family().items>=1,'capacity-two semaphore could not satisfy one acquire')
local a=one:alternative(1)
local available,held=0,0
for _,si in ipairs(a.authority.outputs) do
  local r=a.support and a.support.strands and a.support.strands[si]
  if r and r.protocol=='relay.semaphore.token' then
    if r.state=='available' then available=available+1 elseif r.state=='held' then held=held+1 end
  end
end
eq(available,1,'one acquire did not leave one capacity token')
eq(held,1,'one acquire did not transfer one scarce token to held state')
local two_acq=C.together({S.seed('gate',2),S.acquire('gate'),S.acquire('gate')})
ok(#two_acq:family().items>=1,'capacity-two semaphore could not satisfy two acquires')
eq(#C.together({S.seed('gate',2),S.acquire('gate'),S.acquire('gate'),S.acquire('gate')}):family().items,0,
  'capacity-two semaphore duplicated scarce token authority')
local wrong=C.together({S.seed('gate',1),S.acquire('other')})
eq(#wrong:family().items,0,'semaphore identity failed to refute wrong acquire')
local released=S.release_held(one,'gate')
ok(#released:family().items>=1,'held semaphore token could not be released')
ok(H.no_runtime_words(released:bytes()))
print('PASS cc 42: semaphore capacity is exact scarce-token topology, not counter runtime state ('..count()..')')
