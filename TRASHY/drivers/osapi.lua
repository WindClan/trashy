local globals = driver.getUserlandGlobals()
local os = {}
local envvar = {}
function os.version()
	return chip.version()
end
function os.getenv(var)
	assert(var ~= nil and type(var) == "string","Environment variable keys have to be strings!")
	return envvar[var:lower()]
end
function os.listenv()
	local envs = table.create(#envvar)
	for i,_ in pairs(envvar) do
		table.insert(envs,i)
	end
	return i
end
function os.setenv(var,val)
	assert(var ~= nil and type(var) == "string","Environment variable keys have to be strings!")
	assert(val ~= nil and type(val) == "string" or val == nil,"Environment variables have to be either strings of nil!")
	envvar[var:lower()] = val
end
local months = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31
}
function os.time(opt)
	if not opt then
		return math.floor(chip.getUnixTime())
	end
	assert(opt ~= nil and type(opt) == "table", "The time argument has to be a table!")
	assert(opt.year ~= nil and type(opt.year) == "number", "The time table requires a valid year argument!")
	assert(opt.month ~= nil and type(opt.month) == "number", "The time table requires a valid month argument!")
	assert(opt.day ~= nil and type(opt.day) == "number", "The time table requires a valid day argument!")
	local retTime = 0
	opt.year -= 1970
	opt.hour = opt.hour or 12
	opt.min = opt.min or 0
	opt.sec = opt.sec or 0
	retTime += opt.year * 31536000
	if (opt.year+1970) >= 1970 then
		for i=1970,(opt.year+1970) do
			if (i%4 == 0) and not ((i%100 == 0) and not (i%400 == 0)) then
				retTime += 86400
			end
		end
	else
		for i=(opt.year+1970),1970 do
			if (i%4 == 0) and not ((i%100 == 0) and not (i%400 == 0)) then
				retTime -= 86400
			end
		end
	end
	for i=1,opt.month-1 do
		retTime += months[i] * 86400
	end
	retTime += (opt.day-1)*86400
	retTime += opt.hour*3600
	retTime += opt.min*60
	retTime += opt.sec
	return retTime
end
os.shutdown = chip.shutdown
os.reboot = chip.reboot

globals.os = os