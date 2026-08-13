print("Press any key to continue...")
local event = yield()
while not (event["user"] and event["user"][1] == "keyPressed") do
	event = yield()
end