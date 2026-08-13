local dir = _getCurrentDir()
local disk = _getCurrentDisk()
local toProbe = ({...})[1] or ""

local finalDir = disk..":"..dir.."/"..toProbe
local split = toProbe:split("/")
local match = "^(.*)"
local match1 = table.remove(split) or ""
local finalDir1 = disk..":"..dir.."/"..table.concat(split,"/")
if not files.isDir(finalDir) and files.isDir(finalDir1) then
	finalDir = finalDir1
	match = "^".._makeMatchSafe(match1)
end

local x,y = vterm.getSize()
for _,v in pairs(files.getChildren(finalDir)) do
	if not v:match(match) then
		continue
	end
	files.delete(finalDir.."/"..v)
end