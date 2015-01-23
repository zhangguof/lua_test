-- json.lua
-- implemen json in lua
-- modname:json


--[[
http://www.json.org/json-zh.html
BNF:

object -> {}|{ members }
members -> pair|pair , members
pair -> string : value
array -> []|[ elements ]
elements -> value|value , elements
value->string|number|object|array|true|false|null
string -> ""|" chars "
chars -> char|char chars
char->any-Unicode-character-except-"-or-\-or control-character|
																\"
																\\
																\/
																\b
																\f
																\n
																\r
																\t
																\u four-hex-digits
number -> int|int frac|int exp|int frac exp
int->digit|digit1-9 digits|- digit|- digit1-9 digits
frac -> . digits
exp -> e digits
digits -> digit|digit digits
e -> e|e+|e-|E|E+|E-
--]]


local M={}

local const={["{"]={1,nil},["}"]={1,nil},
				["true"]={4,true},["false"]={4,false},
				['null']={4,nil},
			}

--[[
decode_xxx
get value from string.
--]]


local function decode_number(text, start)
	if start == nil then
		start = 1
	end
	--int -> "[-+]?%d+"
	--frac -> "%.%d+"
	--exp -> "[eE][-+]?%d+"
	--number -> int|int frac|int exp|int frac exp
	
	local number1_reg = "^[-+]?%d+%.%d+[eE][-+]?%d+"
	local number2_reg = "^[-+]?%d+%.%d+"
	local number3_reg = "^[-+]?%d+[eE][-+]?%d+"
	local number4_reg = "^[-+]?%d+"

	local regs = {number1_reg,number2_reg,number3_reg,number4_reg}
	local s,t,value

	for i=1,#regs do
		s, t = string.find(text,regs[i],start)
		if s ~= nil then
			value = tonumber(text:sub(s,t))
			break
		end
	end
	return s,t,value
end

local function decode_string(text, start)
	if start == nil then start=1 end
end

local function decode_const(text, start)
	if start == nil then start=1 end
end




function M.loads(json_str)
	local json_table={}
	return json_table
end

function M.dumps(json_table)
	local json_str
end




--------------------------for test------------------------------------------
local function test_decode_number(input_text,true_value)
	local s, t, value = decode_number(input_text)
	assert(value==true_value,"test_decode_error:"..input_text.."->"..true_value)
end

local function test()

	test_decode_number("0",0)

	test_decode_number("-0",0)
	test_decode_number("+0",0)
	test_decode_number("00000",0)
	test_decode_number("-0.11111",-0.11111)
	test_decode_number("+0.132132321",0.132132321)
	test_decode_number("12321321321321",12321321321321)
	test_decode_number("132131.321321",132131.321321)
	test_decode_number("+123213",123213)
	test_decode_number("-123123",-123123)
	test_decode_number("100e100",100e100)
	test_decode_number("-100e+10",-100e+10)
	test_decode_number("+100e-10",100e-10)
	test_decode_number("-13213.222e+111",-13213.222e111)
	test_decode_number("-123.321e-100xxx",-123.321e-100)
	test_decode_number("-123.321",-123.321)
	test_decode_number("123e1232",123e123)
end

--test()


return M