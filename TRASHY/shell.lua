local args = {...}
if not args[1] == "THIS_IS_THE_KERNEL_PLEASE_LAUNCH_THE_SHELL" then
	vterm.print("The shell does not support nested shells.")
	return
end

local currentDisk = _SYSTEM_DISK
local currentDir = "/"

function _G._getCurrentDisk()
	return currentDisk
end

function _G._setCurrentDisk(d)
	currentDisk = d
	currentDir = ""
end

function _G._getCurrentDir()
	return currentDir
end

function _G._setCurrentDir(d)
	local resolved = {}
	for i,v in pairs(d:split("/")) do
		if v == ".." then
			table.remove(resolved)
		elseif v ~= "." then
			table.insert(resolved,v)
		end
	end
	local newDir = table.concat(resolved,"/").."/"
	if files.isDir(currentDisk..":"..newDir) then
		currentDir = newDir
		return true
	end
	return false
end

function _G.getWorkingPath()
	return currentDisk..":"..currentDir
end

function _G._makeReplaceSafe(str)
	return str:gsub("%%","%%%%"):gsub("%.","%%."):gsub("%+","%%+"):gsub("%$","%%$"):gsub("%-","%%-"):gsub("%^","%%^")
end
function _G._makeMatchSafe(str)
	return _makeReplaceSafe(str):gsub("*","(.*)")
end

local function fileExists(path)
	if files.isFile(path) then
		return path
	elseif files.isFile(path..".lua") then
		return path..".lua"
	elseif files.isFile(path..".bat") then
		return path..".bat"
	end
	return nil
end

local function resolveProgramPath(path)
	local f = fileExists(path) or fileExists(currentDisk..":"..currentDir..path)
	if f then
		return f
	end
	for i,v in pairs(os.getenv("path"):split(";")) do
		if fileExists(v.."/"..path) then
			return fileExists(v.."/"..path)
		end
	end
end

local function runCommand(i)
	if i:sub(#i,#i) == ":" then
		local s,e = pcall(function()
			if files.isDir(i.."/") then
				_setCurrentDisk(i:sub(1,#i-1))
			else
				vterm.print("Invalid device "..i:upper())
			end
		end)
		if not s then
			vterm.print("Invalid device "..i:upper())
		end
		return
	end
	local i1 = i
	for m in i1:gmatch("%%(.*)%%") do
		log(m)
		local val = os.getenv(m) or ""
		i = i:gsub("%%".._makeReplaceSafe(m).."%%",val)
	end
	local sp1 =  i:split(" ")
	local sp = {}
	local last = ""
	local quoted = false
	for _,v in ipairs(sp1) do
		if quoted then
			if v:sub(-1) == '"' then
				quoted = false
				table.insert(sp,last.." "..v:sub(1,-2))
				last = ""
			else
				last ..= " "..v
			end
		else
			if v:sub(1,1) == '"' then
				if v:sub(-1) == '"' then
					table.insert(sp,v:sub(2,-2))
				else
					quoted = true
					last = v:sub(2)
				end
			else
				table.insert(sp,v)
			end
		end
	end
	if quoted then
		table.insert(sp,last)
	end
	local prog = table.remove(sp,1)
	if not prog then
		return
	end
	local progPath = resolveProgramPath(prog:lower())
	if not progPath then
		vterm.print("Bad command or filename - "..prog)
	else
		if progPath:sub(-4) == ".bat" then
			local suc, err = pcall(launchProgram,_SYSTEM_DISK..":TRASHY/runbatch.lua",progPath)
			if not suc then
				vterm.print(err)
			end
		else
			local suc, err = pcall(launchProgram,progPath,table.unpack(sp))
			if not suc then
				vterm.print(err)
			end
		end
	end
	local cursorPos = vterm.getCursorPos()
	if cursorPos ~= 1 then
		vterm.print()
	end
end
os.setenv("path",_SYSTEM_DISK..":TRASHY/path;")
_G.os.execute = runCommand
if files.isFile(_SYSTEM_DISK..":autoexec.bat") then
	launchProgram(_SYSTEM_DISK..":TRASHY/runbatch.lua",_SYSTEM_DISK..":autoexec.bat")
end
while true do
    vterm.write(currentDisk:upper()..":"..currentDir.."> ")
	runCommand(input())
end