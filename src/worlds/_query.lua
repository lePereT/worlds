-- One disposable matching implementation for the public Worlds edge.
--
-- Both W.solve and worlds.query use this instance so compilation caches are
-- shared.  It depends on the verified centre; the centre does not depend on it.
local Edge=require('worlds._edge')
local Public,Private=require('worlds.query_factory')(Edge.centre.public,Edge.private)
return {public=Public,private=Private}
