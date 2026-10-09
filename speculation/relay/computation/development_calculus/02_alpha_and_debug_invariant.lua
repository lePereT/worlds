local H=require('speculation.relay.computation.development_calculus.common')
local ok,eq,count=H.counter()
 local C,T,G=H.C,H.T,H.G
local g,p=G.operation(1,1)
local a=C.atom({geometry=g,theory={variables={'foo','bar'},equalities={T.eq(T.var('foo'),T.var('bar'))}},authority={inputs=p.inputs,outputs=p.outputs},values={inputs={'foo'},outputs={'bar'}},debug='a'})
local b=C.atom({geometry=g,theory={variables={'x','z'},equalities={T.eq(T.var('x'),T.var('z'))}},authority={inputs=p.inputs,outputs=p.outputs},values={inputs={'x'},outputs={'z'}},debug='b'})
eq(a:root(),b:root())
 eq(a:bytes(),b:bytes())
print('PASS td 02: alpha/debug names do not enter semantic identity ('..count()..')')
