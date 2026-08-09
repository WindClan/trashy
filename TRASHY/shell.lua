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

local function fileExists(path)
	if files.isFile(path) then
		return path
	elseif files.isFile(path..".lua") then
		return path..".lua"
	end
	return nil
end

local function resolveProgramPath(path)
	return fileExists(path) or fileExists(_SYSTEM_DISK..":TRASHY/path/"..path) or fileExists(currentDisk..":"..currentDir..path)
end

while true do
    vterm.write(currentDisk:upper()..":"..currentDir.."> ")
    local i = input()
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
		continue
	end
	local sp =  i:split(" ")
	local prog = table.remove(sp,1)
	if not prog then
		continue
	end
	local progPath = resolveProgramPath(prog:lower())
	if not progPath then
		vterm.print("Bad command or filename - "..prog)
	else
		local suc, err = pcall(launchProgram,progPath,table.unpack(sp))
		if not suc then
			vterm.print(err)
		end
	end
	local cursorPos = vterm.getCursorPos()
	if cursorPos ~= 1 then
		vterm.print()
	end
end