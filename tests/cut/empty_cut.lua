local W=require('worlds'); local G=W.Geometry
local N=0; local function eq(a,b,m) N=N+1; assert(a==b,(m or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local b=G.builder(); b:membrane(nil,'empty'); local p=b:finish()
local q=W.Cut.query(p,{})
local k,w=q:step(1); eq(k,'Hit','empty pattern has one empty Cut witness'); eq(#w:closed_inputs(),0)
eq(q:step(1),'Retry','empty Cut witness is unique')
eq(q:stats().steps,0,'empty Cut examines no offers')
print('ok cut/empty_cut.lua',N)
return N
