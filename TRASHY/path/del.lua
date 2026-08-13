local toProbe = ({...})[1] or ""

local split = toProbe:split("/")
local match = "^(.*)"
local match1 = table.remove(split) or ""
local finalDir = getWorkingPath().."/"..table.concat(split,"/")
finalDir = finalDir
match = "^".._makeMatchSafe(match1)

local x,y = vterm.getSize()
for _,v in pairs(files.getChildren(finalDir)) do
	if not v:match(match) then
		continue
	end
	files.delete(finalDir.."/"..v)
end