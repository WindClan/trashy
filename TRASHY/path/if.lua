local args = {...}
if #args >= 2 then
	local sep = table.remove(args,1)
	local com = table.concat(args," ")
	local comp = sep:gsub('"=="',"=="):split("==")
	if #comp == 2 and (comp[1] == comp[2]) then
		os.execute(com)
	end
end