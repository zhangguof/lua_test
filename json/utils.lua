--json.utils

function print_ext(obj,spaces)
	if spaces == nil then spaces="" end
	if type(obj)== 'table' then
		io.write(spaces.."{\n")
		for k,v in pairs(obj) do
			io.write(spaces)
			print_ext(k,spaces.."  ")
			io.write(":")
			if type(v) == "table" then
				io.write("\n")
				print_ext(v,spaces.."  ")
			else
				print_ext(v)
				io.write("\n")
			end
		end
		io.write(spaces.."}\n")

	else
		io.write(spaces)
		io.write(tostring(obj))
	end

end

-- t={'a','b',{['123']=213,['abc']='efg',['xxx']={1,2,3,4,5}},'c','d','e'}
-- print_ext(t)
-- a={}
-- a['abc']=123
-- print_ext(a)