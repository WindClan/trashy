local vars = table.concat({...}," ")
local split = vars:split("=")
if #split ~= 1 then
	local var = table.remove(split,1)
	local val = table.concat(split,"=")
	os.setenv(var,val)
end