local file = table.concat({...}," ")
if not files.isFile(file) and files.isFile(getWorkingPath().."/"..file) then
	file = getWorkingPath().."/"..file
end
if not files.isFile(file) then
	vterm.print("Batch file doesn't exist!")
	return
end
local f = files.open(file,"r")
local fdat = f.read("a")
f.close()
local lines = fdat:gsub("\r\n","\n"):split("\n")
local p = true
for _,v in pairs(lines) do
	local p1 = p
	if v:sub(1,1) == "@" then
		p1 = false
		v = v:sub(2)
	end
	if p1 then
		vterm.write(_getCurrentDisk:upper()..":".._getCurrentDir.."> "..v)
	end
	if v:lower() == "echo off" then
		p = false
	elseif v:lower() == "echo on" then
		p = true
	else
		os.execute(v)
	end
end