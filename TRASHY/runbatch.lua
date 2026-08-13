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
local labels = {}
local i = 1
while i <= #lines do
	local v = lines[i]
	if v:sub(1,1) == ":" then
		labels[v:sub(2):lower()] = i
		table.remove(lines,i)
		i-=1
	end
	i+=1
end
for i,v in ipairs(lines) do

end
local p = true
local i = 1
while i <= #lines do
	local v = lines[i]
	local p1 = p
	if v:sub(1,1) == "@" then
		p1 = false
		v = v:sub(2)
	end
	if v:sub(1,5) == "goto " then
		local label = v:sub(6):lower()
		if labels[label] then
			i = labels[label]
			continue
		end
	end
	if p1 then
		print(_getCurrentDisk():upper()..":".._getCurrentDir().."> "..v)
	end
	if v:lower() == "echo off" then
		p = false
	elseif v:lower() == "echo on" then
		p = true
	else
		os.execute(v)
	end
	i += 1
end