local toProbe = ({...})[1] or ""

local finalDir = getWorkingPath().."/"..toProbe
local split = toProbe:split("/")
local match = "^(.*)"
local match1 = table.remove(split) or ""
local finalDir1 = getWorkingPath().."/"..table.concat(split,"/")
if not files.isDir(finalDir) and files.isDir(finalDir1) then
	finalDir = finalDir1
	match = "^".._makeMatchSafe(match1)
end

local x,y = vterm.getSize()
for _,v in pairs(files.getChildren(finalDir)) do
	if not v:match(match) then
		continue
	end
	local stringToPrint = v
	if files.isDir(finalDir.."/"..v) then
		stringToPrint ..= "/"
	end
	stringToPrint ..= " "
	local xPos = vterm.getCursorPos()
	if xPos+#stringToPrint > x then
		vterm.print()
	end
	vterm.write(stringToPrint)
end