-- virtual terminal for trashy
-- since its vital to literally everything the OS does it's not a driver.
local sizeX1,sizeY1 = screen.getSize()
local termSizeX, termSizeY = math.floor((sizeX1-1)/8)*8, math.floor((sizeY1-1)/16)*16
local topX, topY = (sizeX1/2)-(termSizeX/2), (sizeY1/2)-(termSizeY/2)
local termTable = table.create((termSizeY/16)*(termSizeX/8))
for i=1,termSizeY/16 do
    local a = table.create(termSizeX/8)
    for i1=1,termSizeX/8 do
        table.insert(a," ")
    end
    table.insert(termTable,a)
end

--the vterm uses a VGA BIOS font taken from here https://github.com/viler-int10h/vga-text-mode-fonts
--it has a limited character set but it SHOULD be in the clear copyright wise since its taken from 80s hardware
--its also era appropriate
local color = string.char(220, 220, 200, 255)
local none = string.char(0, 0, 0, 0)
local bkgSquare = string.char(0, 0, 0, 255):rep(128)
local fonTable = {}
local f = files.open(_SYSTEM_DISK..":/TRASHY/ATI8X16.F16","rb")
for i=0,255 do
	local fnt = {}
	for _=1,16 do
		local lineDat = string.byte(f.read(1))
		for x=0,7 do
            table.insert(fnt,(((lineDat >> 8-x) & 1)~=0 and color or none)) --for some reason the font is Big Endian
        end
	end
	fonTable[i] = table.concat(fnt)
end
f.close()

local x,y = 1,1
local sizeX, sizeY = termSizeX/8, termSizeY/16
local vterm = {}
function vterm.drawChar(x,y,c)
	if not type(c) == "string" then
		error("invalid char!!")
	end
	c = c:sub(1,1)
	local charNum = fonTable[string.byte(c)] or fonTable[0]
	screen.drawPixels(topX+((x-1)*8)+1,topY+((y-1)*16)+1,charNum,8,16)
end
function vterm.blankChar(x,y)
	screen.drawPixels(topX+((x-1)*8)+1,topY+((y-1)*16)+1,bkgSquare,8,16)
end
function vterm.draw()
    screen.fill(0,0,0)
    for y,v in pairs(termTable) do
        for x,c in pairs(v) do
			if c ~= " " then
				vterm.drawChar(x,y,c)
			end
        end
    end
    screen.draw()
end

function vterm.setChar(c,x1,y1)
    if not x1 then
        x1 = x
    end
    if not y1 then
        y1 = y
    end
    if c == "" then
        c = " "
    end
	c = c:sub(1,1)
    if termTable[y1] and termTable[y1][x1] then
		local old = termTable[y1][x1]
		if old ~= " " then
			vterm.blankChar(x,y)
		end
        termTable[y1][x1] = c
		vterm.drawChar(x1,y1,c)
		screen.draw()
    end
end

function vterm.setCursorPos(x1,y1)
    x,y = x1,y1
end

function vterm.getCursorPos()
    return x,y
end

function vterm.getSize()
    return sizeX,sizeY
end

function vterm.write(str)
	str = tostring(str)
    local split = {}
    for i=1,#str do
        table.insert(split,str:sub(i,i))
    end
    for i,v in pairs(split) do
        if termTable[y][x] then
			local old = termTable[y][x]
			if old ~= " " then
				vterm.blankChar(x,y)
			end
            termTable[y][x] = v
			vterm.drawChar(x,y,v)
			screen.draw()
        end
        x = x + 1
    end
    screen.draw()
end

function vterm.print(...)
	local str = ""
	for i,v in pairs({...}) do
		str ..= tostring(v)
		if i ~= #str then
		 str ..= " "
		end
	end
    local split = {}
    for i=1,#str do
        table.insert(split,str:sub(i,i))
    end
    for i,v in pairs(split) do
		if v == "\n" then 
			x += sizeX*50
		else
			if termTable[y][x] then
				local old = termTable[y][x]
				if old ~= " " then
					vterm.blankChar(x,y)
				end
				termTable[y][x] = v
				vterm.drawChar(x,y,v)
				screen.draw()
			end
			x = x + 1
			if x > sizeX then
				y = y + 1
				x = 1
				if y > sizeY then
					y = sizeY
					vterm.scroll(1);
				end
			end
		end
    end
    x = 1
    y = y + 1
    if y > sizeY then
        vterm.scroll(1);
    end
	screen.draw()
end

function vterm.scroll(i)
    for i1=i, sizeY do
        termTable[i1-i+1] = termTable[i1+1]
    end
    for i1=sizeY-i+1,sizeY do
        local a = table.create(sizeX)
        for i1=1,sizeX do
            table.insert(a," ")
        end
        termTable[i1] = a
    end
    y = y-i
    if y < 1 then
        y = 1;
    end
    vterm.draw()
end

function vterm.clear()
	local newTable = table.create(sizeX*sizeY)
	for i=1,sizeY do
		local a = table.create(sizeX)
		for i1=1,sizeX do
			table.insert(a," ")
		end
		table.insert(newTable,a)
	end
	termTable = newTable
	vterm.draw()
end

return vterm
