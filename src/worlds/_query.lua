-- One disposable matching implementation for the public Worlds edge.
--
-- Both W.solve and worlds.query use this instance so compilation caches are
-- shared.  It depends on the verified centre; the centre does not depend on it.
local Kernel=require('worlds._kernel')
local Public,Private=require('worlds.query_factory')(Kernel.public,Kernel.private)
return {public=Public,private=Private}
