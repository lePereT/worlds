package.path='./src/?.lua;'..package.path
local W=require('worlds'); local M,Att=W.Model,W.Att
local passed=0
local function test(n,f) io.write(string.format('%-92s ',n)); local ok,e=pcall(f); if not ok then print('FAIL'); error(e,0) end; passed=passed+1; print('ok') end
local function witness(F,p,fixed) local q=F:query(p,fixed); local s,w=q:step(math.huge); assert(s=='hit'); return w end
local function pair(shared)
  local m=M.new('O'); local O=m.actuality; local P=m:point('P',O,'P'); local K=m:world('K',O); local s1=m:strand('s1',K,{P},'R'); local s2=m:strand('s2',K,{P},'R')
  local D1=m:world('D1'); local G1=m:world('G1'); local g1=m:strand('g1',D1,{P},'R'); local o1=m:strand('o1',D1,{P},'R'); m:face('a',G1,{g1},{o1},'A')
  local D2=m:world('D2'); local G2=m:world('G2'); local g2=m:strand('g2',D2,{P},'R'); local o2=m:strand('o2',D2,{P},'R'); m:face('b',G2,{g2},{o2},'B')
  local F=Att.at(m,K); local p1,p2=Att.patch(m,g1),Att.patch(m,g2)
  local wa=witness(F,p1,{{demand=g1,supply=s1}}); local wb=witness(F,p2,{{demand=g2,supply=shared and s1 or s2}})
  return m,K,F,wa,wb
end

test('1. public API is one Att relation',function() assert(W.Att and not W.Attachment and not W.Residual and not W.Frontier) end)
test('2. live actual Frontier attaches, residualises and grafts exact Witness',function()
  local m=M.new('O'); local O=m.actuality; local P=m:point('P',O,'P'); local K=m:world('K',O); local s=m:admit('s',K,{P},'R')
  local D=m:world('D'); local G=m:world('G'); local g=m:strand('g',D,{P},'R'); local out=m:strand('out',D,{P},'R'); m:face('f',G,{g},{out},'A')
  local F=Att.at(m,K); local p=Att.patch(m,g); local w=witness(F,p,{{demand=g,supply=s}}); local R=w:after(); assert(#R:offers()==1); w:graft(); assert(not w:valid())
end)
test('3. disjoint cross-patch exact occurrences derive square',function() local _,_,F,a,b=pair(false); local ok,p=Att.coherence(F,{a,b}); assert(ok and p.dimension==2 and p.vertex_count==4) end)
test('4. competing exact occurrences fail square completion',function() local _,_,F,a,b=pair(true); local ok=Att.coherence(F,{a,b}); assert(not ok) end)
test('5. pointed Cut derives causal order and rejects false square',function()
  local m=M.new('O'); local O=m.actuality; local P=m:point('P',O,'P'); local K=m:world('K',O); local s=m:strand('s',K,{P},'R')
  local D=m:world('D'); local G=m:world('G'); local g=m:strand('g',D,{P},'R'); local mid=m:strand('mid',G,{P},'R'); local out=m:strand('out',D,{P},'R'); local a=m:face('a',G,{g},{mid},'A'); local b=m:face('b',G,{mid},{out},'B')
  local F=Att.at(m,K); local w=witness(F,Att.patch(m,g),{{demand=g,supply=s}}); local c=w:cut(); assert(c:enabled()[1]==a); assert(not Att.coherence(c,{a,b})); assert(c:after(a):enabled()[1]==b)
end)
test('6. immutable Certified Reader uses same Att and cannot graft',function()
  local m=M.new('O'); local O=m.actuality; local P=m:point('P',O,'P'); local K=m:world('K',O); m:admit('s',K,{P},'R')
  local D=m:world('D'); local G=m:world('G'); local g=m:strand('g',D,{P},'R'); local out=m:strand('out',D,{P},'R'); m:face('f',G,{g},{out},'A')
  local r=W.Certified.read(W.Certified.certify(m)); local ps=Att.patches(r); assert(#ps==1); local F=Att.at(r,K.serial); local ws=F:witnesses(ps[1]); assert(#ws==1); local R=ws[1]:after(); assert(R); local ok=pcall(function() ws[1]:graft() end); assert(not ok)
end)
print(string.format('%d/%d unified Att tests passed',passed,passed))
