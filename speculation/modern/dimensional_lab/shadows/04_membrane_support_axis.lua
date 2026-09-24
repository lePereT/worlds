package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds'); local C=require('speculation.modern.dimensional_lab.shadows.cellular')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

print('1. identical cellular incidence can be hosted at different Membrane supports')
local root,rx=C.cycle(4,5,{label='root-host'})
local left,lx=C.cycle(4,5,{label='child-host',child_host='child'})
eq(#root:points(),#left:points()); eq(#root:strands(),#left:strands()); eq(#root:faces(),#left:faces()); ok(root:is_developable() and left:is_developable())
eq(W.membrane(rx.f),rx.root,'root-hosted fill'); ok(W.membrane(lx.f)~=lx.root,'same incidence may occupy a proper child support')

print('2. with a fixed support tree, the same fill may inhabit root or either sibling')
local function hosted(where)
 local b=W.builder(); local r=b:membrane(nil,'r'); local a=b:membrane(r,'a'); local z=b:membrane(r,'b'); local p,e={},{}
 for i=1,4 do p[i]=b:point(r,'p'..i) end; for i=1,4 do e[i]=b:strand(r,{p[i],p[i%4+1]},'e'..i) end
 local h=where=='r' and r or where=='a' and a or z; local f=b:face(h,{e[1],e[3]},{e[2],e[4]},'fill'); return b:finish(),{r=r,a=a,b=z,f=f}
end
local gr,r=hosted('r'); local ga,a=hosted('a'); local gb,b=hosted('b')
for _,g in ipairs{gr,ga,gb} do eq(#g:membranes(),3); eq(#g:points(),4); eq(#g:strands(),4); eq(#g:faces(),1); ok(g:is_developable()) end
ok(W.name(W.membrane(r.f))~=W.name(W.membrane(a.f))); ok(W.name(W.membrane(a.f))~=W.name(W.membrane(b.f)))

print('3. causal SCC normalisation one rank up rehosts at LCA without identifying child supports')
local function half(name)
 local x=W.builder(); local rr=x:membrane(nil,name..'.root'); local c=x:membrane(rr,name..'.child')
 local extin=x:strand(rr,{},name..'.extin'); local cin=x:strand(rr,{},name..'.cin'); local cout=x:strand(rr,{},name..'.cout'); local extout=x:strand(rr,{},name..'.extout')
 local f=x:face(c,{extin,cin},{cout,extout},name..'.higher'); return x:finish(),{root=rr,child=c,cin=cin,cout=cout,f=f}
end
local A,x=half('A'); local B,y=half('B'); local G,img=W.join({A,B},{{from=x.cout,to=y.cin},{from=y.cout,to=x.cin}})
eq(#G:faces(),1); local j=img[x.f]; eq(j,img[y.f]); eq(W.membrane(j),img[x.root]); eq(W.membrane(j),img[y.root]); ok(img[x.child]~=img[y.child],'siblings survive while joint event moves to common support')
print('PASS membrane/support axis pressure',n,'assertions')
