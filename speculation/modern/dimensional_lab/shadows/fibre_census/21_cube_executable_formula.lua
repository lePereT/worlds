package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local F=require('speculation.modern.dimensional_lab.shadows.fibre_census.common')
local n=0
local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end
local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local allowed_masks={
  [0]=true,
  [1<<4]=true, [1<<5]=true,
  [(1<<4)|(1<<5)]=true, [(1<<3)|(1<<4)]=true,
  [(1<<3)|(1<<4)|(1<<5)]=true, [(1<<2)|(1<<3)|(1<<4)]=true,
  [(1<<2)|(1<<3)|(1<<4)|(1<<5)]=true, [(1<<1)|(1<<2)|(1<<3)|(1<<4)]=true,
  [(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)]=true,
}

local function predicted(states)
  local mask=0; local used={}
  for i,s in ipairs(states) do
    if s~=0 then
      mask=mask | (1<<(i-1))
      if s>=2 then if used[s] then return false end; used[s]=true end
    end
  end
  return not not allowed_masks[mask]
end

local function build(q,code)
  local states={}; local x=code; for i=1,6 do states[i]=x%q; x=math.floor(x/q) end
  local b=W.builder(); local root=b:membrane(nil,'root'); local child={}; for s=2,q-1 do child[s]=b:membrane(root,'C'..(s-1)) end
  local vertices={'000','001','010','011','100','101','110','111'}; local p={}; for _,v in ipairs(vertices) do p[v]=b:point(root,v) end
  local es={}; for ei,e in ipairs(F.cube_edges) do es[ei]=b:strand(root,{p[e[1]],p[e[2]]},e[3]) end
  for fi,face in ipairs(F.cube_faces) do if states[fi]~=0 then
    local ins,outs={},{}
    for _,ei in ipairs(F.cube_face_edges[fi]) do
      local os=F.cube_owners[ei]; local other=os[1]==fi and os[2] or os[1]
      if F.cube_order[face.name]<F.cube_order[F.cube_faces[other].name] then outs[#outs+1]=es[ei] else ins[#ins+1]=es[ei] end
    end
    local host=states[fi]==1 and root or child[states[fi]]
    b:face(host,ins,outs,face.name)
  end end
  return b:finish(),states
end

local function fall(m,j) local z=1; for i=0,j-1 do z=z*(m-i) end; return z end
local function choose(a,b) if b<0 or b>a then return 0 end; local z=1; for i=1,b do z=z*(a-i+1)//i end; return z end
local function support_count(k,m)
  local z=0; for j=0,math.min(k,m) do z=z+choose(k,j)*fall(m,j) end; return z
end
local function predicted_count(q)
  local m=q-2
  return 1 + 2*(support_count(1,m)+support_count(2,m)+support_count(3,m)+support_count(4,m)) + support_count(5,m)
end

print('1. executable cube states factor exactly into a causal filling mask and injective off-spine support choices')
local expected={[2]=10,[3]=35,[4]=120,[5]=385,[6]=1118}
for q=2,6 do
  local actual=0
  for code=0,q^6-1 do
    local x=code; local st={}; for i=1,6 do st[i]=x%q; x=math.floor(x/q) end
    local expect=predicted(st)
    local good,g=pcall(build,q,code); local develops=good and g:is_developable()
    eq(develops,expect,'q='..q..' code='..code)
    if develops then actual=actual+1 end
  end
  eq(actual,expected[q]); eq(actual,predicted_count(q))
end

print('2. the ten causal masks are fixed; all branching growth is support-realisation growth')
local byk={}; for mask in pairs(allowed_masks) do local k=F.popcount(mask); byk[k]=(byk[k] or 0)+1 end
local want={1,2,2,2,2,1}; for k=0,5 do eq(byk[k],want[k+1],'mask multiplicity at '..k..' Faces') end

print('3. the closed form predicts the independently observed larger censuses')
eq(predicted_count(7),2895); eq(predicted_count(8),6700)
-- Those q=7/q=8 values were also materialised exhaustively during the shadow dive;
-- keeping the routine regression at q<=6 avoids adding ~50s to speculation-check.
print('PASS cube executable-factorisation law',n,'assertions')
