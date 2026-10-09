local H=require('speculation.relay.computation.concurrency_discovery.common')
local ok,eq,count=H.counter()
local p=H.C.together({
  H.Channel.send('wire',5),H.Channel.recv('wire'),
  H.Cell.empty('box'),H.Cell.put('box',8),H.Cell.take('box')})
eq(#p:family().items,1,'heterogeneous protocols needed an adapter or left ambiguity')
eq(H.value(p,1,1),5,'channel result changed in mixed network')
eq(H.value(p,1,2),8,'cell result changed in mixed network')
local a=p:alternative(1)
eq(#a.geometry.faces,4,'mixed network did not contain one rendezvous Face plus three cell Faces')
-- Canonical rank places the independent rendezvous at either edge of the rank-0 cell source. It
-- must remain causally incomparable with the terminal cell transition in at least both directions.
local independent=false
for i=1,4 do for j=1,4 do if i~=j and
    not H.G.face_reaches(a.geometry,i,j) and not H.G.face_reaches(a.geometry,j,i) then independent=true end end end
ok(independent,'mixed protocols were spuriously serialised together')
ok(H.no_runtime_words(p:bytes()))
print('PASS cc 30: channel and cell protocols coexist under one universal together ('..count()..')')
