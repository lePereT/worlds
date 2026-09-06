local S=require('tests.support')
local G=S.G
local function graph(shared)
  local b=G.builder(); local K=b:membrane(nil,'term')
  local p=b:point(K,'Atom'); local q=shared and p or b:point(K,'Atom')
  b:strand(K,'Left',{p}); b:strand(K,'Right',{q})
  return b:finish(), {[p]='a',[q]='a'}
end
local shared,sa=graph(true); local copied,ca=graph(false)
S.no(S.Worlds.same(shared,copied),'sharing is exact intensional geometry')
local function unfold(g,a)
  local out={}
  for _,s in ipairs(g:strands()) do local c=g:cell(s); out[c.sort]=a[c.points[1]] end
  return out.Left..','..out.Right
end
S.eq(unfold(shared,sa),unfold(copied,ca),'extensional term observation forgets sharing')
print('ok 29_term_sharing')
