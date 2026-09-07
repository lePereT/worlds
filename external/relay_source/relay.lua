local Syntax=require('syntax'); local Compiler=require('compiler'); local M={}
function M.compile_text(text) local ast=Syntax.parse(text); local c=Compiler.new(ast); return c,c:run() end
function M.compile_file(path) local f=assert(io.open(path,'rb')); local t=f:read('*a'); f:close(); return M.compile_text(t) end
return M
