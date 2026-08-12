local num = tonumber(({...})[1]) or 0.25
while true do
	print("sleep("..num..") took "..sleep(num).." seconds")
end