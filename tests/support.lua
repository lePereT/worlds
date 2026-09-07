local T={n=0}
function T.ok(x,msg) T.n=T.n+1; assert(x,msg or 'expected truthy') end
function T.eq(a,b,msg) T.n=T.n+1; assert(a==b,msg or (tostring(a)..' ~= '..tostring(b))) end
function T.count() return T.n end
return T
