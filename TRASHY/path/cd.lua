local args = table.concat({...}," ")
local currentDir = _getCurrentDir()
_setCurrentDir(currentDir..args)