-- test_json.lua
function print_table(t)
	print("{")
	for k,v in pairs(t) do
		print(k,":",v,",")
	end
	print("}")
end


local  json = require("json")

s="{'a':1,'b':2}"
print_table(json.loads(s))
