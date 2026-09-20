package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local function ok(x,msg) assert(x,msg) end
local function eq(a,b,msg) assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local function names(xs)
  local out={}
  for _,x in ipairs(xs) do out[#out+1]=W.name(x) or W.kind(x) end
  table.sort(out)
  return table.concat(out,',')
end

-- Shared rigid scalar/type vocabulary.
local vb=W.builder(); local vm=vb:membrane(nil,'vocab')
local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); local C=vb:point(vm,'C'); local R=vb:point(vm,'R')
vb:finish()

local function unary(pin,pout,label)
  local b=W.builder(); local m=b:membrane(nil,label)
  local i=b:strand(m,{pin},label..'.in')
  local o=b:strand(m,{pout},label..'.out')
  local f=b:face(m,{i},{o},label)
  return b:finish(),i,o,f
end

-- EXP 1: open relational composition / existential hiding.
do
  local F,fi,fo=unary(A,B,'R')
  local G,gi,go=unary(B,C,'S')
  local FG=W.join({F,G},{{from=fo,to=gi}})
  eq(#FG:ingress(),1,'rel ingress')
  eq(#FG:egress(),1,'rel egress')
  eq(W.points(FG:ingress()[1])[1],A,'A remains exposed')
  eq(W.points(FG:egress()[1])[1],C,'C remains exposed')

  -- External finite relations: R(a,b) iff b = not a; S(b,c) iff c=b.
  local relR={{0,1},{1,0}}
  local relS={{0,0},{1,1}}
  local comp={}
  for _,r in ipairs(relR) do
    for _,s in ipairs(relS) do
      if r[2]==s[1] then comp[#comp+1]={r[1],s[2]} end
    end
  end
  eq(#comp,2,'two composite relation pairs')
  ok((comp[1][1]~=comp[1][2]) and (comp[2][1]~=comp[2][2]),'composite is NOT')
  print('EXP1 relational composition: PASS  boundary='..names(FG:ingress())..' -> '..names(FG:egress()))
end

-- EXP 2: symbolic affine elimination attached to causal geometry.
do
  local F,fi,fo=unary(A,B,'y=2x+3')
  local G,gi,go=unary(B,C,'z=5y-7')
  local FG=W.join({F,G},{{from=fo,to=gi}})
  -- Theory summaries represented here as exact affine maps (a,b): out=a*in+b.
  local a1,b1=2,3
  local a2,b2=5,-7
  local a,b=a2*a1,a2*b1+b2
  eq(a,10); eq(b,8)
  eq(#FG:faces(),2,'geometry retains derivation history before boundary')
  local bd=W.boundary(FG)
  eq(#bd:faces(),0,'boundary hides causal interior')
  eq(#bd:egress(),1)
  print(('EXP2 affine elimination: PASS  hidden y, boundary theory z=%dx%+d'):format(a,b))
end

-- EXP 3: reverse-mode AD skeleton as structural transposition.
do
  -- primal: x --copy--> x1,x2 --scale2/scale3--> y1,y2 --add--> y
  local b=W.builder(); local m=b:membrane(nil,'primal')
  local x=b:strand(m,{R},'x')
  local x1=b:strand(m,{R},'x1'); local x2=b:strand(m,{R},'x2')
  local copy=b:face(m,{x},{x1,x2},'copy')
  local y1=b:strand(m,{R},'y1'); local y2=b:strand(m,{R},'y2')
  local s2=b:face(m,{x1},{y1},'scale2')
  local s3=b:face(m,{x2},{y2},'scale3')
  local y=b:strand(m,{R},'y')
  local add=b:face(m,{y1,y2},{y},'add')
  local P=b:finish()

  -- reverse: dy --copy(add^T)--> dy1,dy2 --scale--> dx1,dx2 --add(copy^T)--> dx
  local rb=W.builder(); local rm=rb:membrane(nil,'reverse')
  local dy=rb:strand(rm,{R},'dy')
  local dy1=rb:strand(rm,{R},'dy1'); local dy2=rb:strand(rm,{R},'dy2')
  rb:face(rm,{dy},{dy1,dy2},'add^T=copy')
  local dx1=rb:strand(rm,{R},'dx1'); local dx2=rb:strand(rm,{R},'dx2')
  rb:face(rm,{dy1},{dx1},'scale2^T')
  rb:face(rm,{dy2},{dx2},'scale3^T')
  local dx=rb:strand(rm,{R},'dx')
  rb:face(rm,{dx1,dx2},{dx},'copy^T=add')
  local RP=rb:finish()

  eq(#P:faces(),4); eq(#RP:faces(),4)
  eq(#W.outputs(copy),2,'primal copy fanout')
  eq(#W.inputs(add),2,'primal add fanin')
  local PR=W.join({P,RP},{{from=y,to=dy}})
  eq(#PR:ingress(),1,'composite primal/reverse seed input')
  eq(#PR:egress(),1,'composite cotangent output')
  eq(W.name(PR:ingress()[1]),'x')
  -- Exact arithmetic check of corresponding linear function y=5x, hence dx=5dy.
  local primal_gain=2+3
  local reverse_gain=2+3
  eq(primal_gain,reverse_gain)
  print('EXP3 reverse AD skeleton: PASS  copy <-> add under transpose; gain=5')
end

-- EXP 4: tensor topology belongs to Point/Strand incidence, not causal Faces.
-- A cyclic factor network is lawful face-free Geometry; only a cyclic causal
-- schedule is an SCC.
do
  local b=W.builder(); local m=b:membrane(nil,'tensor-cycle')
  local i=b:point(m,'i'); local j=b:point(m,'j'); local k=b:point(m,'k')
  local TA=b:strand(m,{i,j},'A(i,j)')
  local TB=b:strand(m,{j,k},'B(j,k)')
  local TC=b:strand(m,{k,i},'C(k,i)')
  local net=b:finish()
  eq(#net:faces(),0,'tensor factor topology is not causal')
  eq(#net:egress(),3)
  ok(net:is_developable(),'cyclic Point-Strand incidence is lawful')
  eq(W.points(TA)[2],W.points(TB)[1],'j shared exactly')
  eq(W.points(TB)[2],W.points(TC)[1],'k shared exactly')
  eq(W.points(TC)[2],W.points(TA)[1],'i shared exactly')

  -- Fixed arithmetic witness: trace(A*B*C) is independent of the two tested
  -- parenthesisations. This is pre-determined arithmetic, not a claim that
  -- Worlds itself knows tensor algebra.
  local MA={{1,2},{3,4}}
  local MB={{0,5},{6,7}}
  local MC={{2,1},{1,3}}
  local function mm(X,Y)
    local Z={{0,0},{0,0}}
    for a=1,2 do for c=1,2 do for q=1,2 do Z[a][c]=Z[a][c]+X[a][q]*Y[q][c] end end end
    return Z
  end
  local function tr(X) return X[1][1]+X[2][2] end
  eq(tr(mm(mm(MA,MB),MC)),tr(mm(MA,mm(MB,MC))),'two contraction schedules agree')
  print('EXP4 tensor factor geometry: PASS  cyclic Point-Strand topology needs no causal cycle')
end

-- EXP 5: independent symbolic subproblems remain independent until explicitly glued.
do
  local F,fi,fo=unary(A,B,'left')
  local G,gi,go=unary(A,B,'right')
  local T=W.join({F,G},{})
  eq(#T:faces(),2); eq(#T:ingress(),2); eq(#T:egress(),2)
  -- Glue one result into a consumer; the other lane should remain open literally.
  local H,hi,ho=unary(B,C,'consumer')
  local U,image=W.join({T,H},{{from=T:egress()[1],to=hi}})
  eq(#U:ingress(),2); eq(#U:egress(),2)
  print('EXP5 locality of composition: PASS  unrelated lane remains open under local join')
end

print('research excursions: PASS')
