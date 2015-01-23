days = {'sunday','monday','tuesday','wednesday'}

a = {x=100,y=2222}
-- print(a)
-- print(math.cos(3.14))

local x = "hello lua test."
-- print(x)
-- print(string.find(x,"lua"))
-- print(string.sub(x,7))


-- for test
function list_iter( t )
	local i = 0
	local n = #t--table.getn(t)
	return function ()
	i = i+1
	if i <= n then return t[i] end
		-- body
	end
end

local t = {10,20,30,40}

iter = list_iter(t)
while true do
	local element = iter()
	if element == nil then break end
	--print(element)
end

for k, v in pairs(t) do
	--print(k,v)
end
function print_table(t)
	print("{")
	for k,v in pairs(t) do
		print(k,":",v,",")
	end
	print("}")
end

-- print_table(t)
-- print_table(package.loaded)
-- print_table(package.searchers)
-- print(package.path)
mod_a = require("mod.modA")
mod_b = require("mod.modB")

-- print(mod_a.add(1,20))
-- print(mod_b.add(20,20))
-- print(mod_a.g_var)

-- tt={["aaa"]=123,["bbb"]=321}
-- print(tt.aaa)
-- print(tt['bbb'])
-- print(string.sub("abc",2))
text="ddxxdsfda"
print(text:sub(2,3))

a={'a','b','c'}
for i=1,#a do
	print(a[i])
end