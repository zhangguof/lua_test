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
	if s==nil then error("decode number error:"..text.."@"..start) end

	return s,t,value
end


--[[
U-00000000 - U-0000007F: 0xxxxxxx
U-00000080 - U-000007FF: 110xxxxx 10xxxxxx
U-00000800 - U-0000FFFF: 1110xxxx 10xxxxxx 10xxxxxx
----not use-----：
U-00010000 - U-001FFFFF: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
U-00200000 - U-03FFFFFF: 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
U-04000000 - U-7FFFFFFF: 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
--]]

local bit_map = {[0]=1,[1]=2,[2]=4,[3]=8,[4]=16,
		   [5]=32,[6]=64,[7]=128,[8]=256,[9]=512,
		   [10]=1024,[11]=2048,[12]=4096,[13]=8192,
		   [14]=16384,[15]=32768,[16]=65536,
		  }

local function right_shift(value,n)
	--右移
	local mask=bit_map[n] or 2^n
	return math.floor(value/mask)
end
local function left_shift(value,n)
	local mask=bit_map[n] or 2^n
	return value * mask
end
local function low_n_bits(value,n)
	mask=bit_map[n] or 2^n
	return value - right_shift(value,n) * mask
end


local function unicode_to_utf8(code)
	--"你" = "\u4f60" = "\xe4\xbd\xa0" = "\228 \189 \160"
	--0b110 = 0x6, 0b10= 0x2, 0b1110=0xe
	--print('----:'..code)
	local hex_code = tonumber(code)
	if hex_code>=0 and hex_code<=0x7f then
		return string.char(hex_code)
	elseif hex_code >= 0x80 and hex_code<=0x7ff then
		local hb = right_shift(hex_code,6)--math.floor(hex_code/0x40)
		local lb = low_n_bits(hex_code,6)--hex_code - hb*0x40

		local b1 = left_shift(0x6,5) + hb--0x6*0x20 + hb
		local b2 = left_shift(0x2,6) + lb--0x2*0x40 + lb
		return string.char(b1)..string.char(b2)
	elseif hex_code >= 0x800 and hex_code <=0xffff then
		
		local p1 = right_shift(hex_code,12)--math.floor(hex_code/0x1000)
		local p2 = right_shift(hex_code,6)--math.floor(hex_code/0x40)
		p2 = low_n_bits(p2,6)
		local p3 = low_n_bits(hex_code,6)--hex_code - p2*0x40
		
		
		--local b1,b2,b3 = 0xe*0x10 + p1, 0x2*0x40 + p2, 0x2*0x40 + p3
		local b1, b2, b3 = left_shift(0xe,4) + p1,
						   left_shift(0x2,6) + p2,
						   left_shift(0x2,6) + p3

 		return string.char(b1)..string.char(b2)..string.char(b3)
	else
		error("unicode2utf8 error,out of range"..code)
	end
	-- body
end

local function int2hex(num)
	local value,a,b = "",nil,nil
	local h_map = {['10']='a',['11']='b',['12']='c',
				   ['13']='d',['14']='e',['15']='f'}
	while num > 0 do
		a = math.floor(num/16)
		b = num - a*16
		if b>=10 then
			b = h_map[tostring(b)]
		else
			b = tostring(b)
		end

		value = b..value
		num = a
	end
	return value
end

local function utf8_to_unicode(text)

	local c1 = string.byte(text:sub(1,1))
	local c2,c3 = nil,nil
	if c1 >= 0x80 then
		c2 = string.byte(text:sub(2,2))
	end

	if c1>=0xe0 then
		c3 = string.byte(text:sub(3,3))
	end

	assert(c1<=0xef,"utf8 to unicode error:out of range:"..c1)

	if c3 ~= nil then
		-- local b1, b2, b3 = c1 - math.floor(c1/0x20), c2 - math.floor(c2/0x40),
		-- 				   c3 - math.floor(c3/0x40)
		local b1, b2, b3 = low_n_bits(c1,4),
						   low_n_bits(c2,6),
						   low_n_bits(c3,6)

		--b1*0x1000 + b2*0x40 + b3
		local u = left_shift(b1,12) + left_shift(b2,6) + b3
		return "\\u"..int2hex(u)

	elseif c2 ~=nil then
		local b1, b2 = low_n_bits(c1,5),
					   low_n_bits(c2,6)

		local u = left_shift(b1,6) + b2

		return "\\u"..int2hex(u)

	else

	end

end

local function translate_string(text)
	trans = {['\\"']='"',['\\\\']='\\',['\\/']='/',
			 ['\\b']='\b',['\\f']='\f',['\\n']='\t',
			 ['\\r']='\r',['\\t']='\t'
			}
	unicode_reg = '\\u(....)'

	for k,v in pairs(trans) do
		text = string.gsub(text,k,v)
	end

	text=string.gsub(text,unicode_reg,function (t)
		return unicode_to_utf8("0x"..t)
		end
		)
		-- body

	--print(text)
	return text
end

local function decode_string(text, start)
	if start == nil then start=1 end
	local s, t, value
	reg = '".-[^\\]"'
	s, t=string.find(text,reg,start)
	if s ~= nil then
		value = text:sub(s+1,t-1)
		value = translate_string(value)
	else
		error("decode string error:"..text.."@"..start)
	end
	return s,t,value
end

local const_map={{'^true',true},
				 {'^false',false},
				 {'^null',nil}
				}

local function decode_const(text, start)
	if start == nil then start=1 end
	local s, t
	for i=1,#const_map do
		local r,v = const_map[i][1], const_map[i][2]
		s, t = string.find(text,r,start)
		if s ~= nil then
			return s,t,v
		end
	end
	return nil
end

function skip_char(text,start,char)
	assert(text:sub(start,start)==char,
		"skip_char error in text:<"..text..">post:"..start.."(expect "..char..",got "..text:sub(start,start)..").")
end



local function decode_value(text, start)
	if start == nil then start=1 end
	char = text:sub(start,start)
	local s,t,v
	if char == "{" then
		return M.decode_object(text,start)

	elseif char == "[" then
		return M.decode_arrary(text,start)

	elseif char =='"' then
		return decode_string(text,start)
	else
		s,t = string.find(char,"^%d")
		if s ~= nil then
			return decode_number(text,start)
		end

		s,t,v = decode_const(text,start)
		if s ~= nil then
			return s,t,v
		end
		error("decode value error:"..text.."@"..start)
	end
end



function M.decode_object(text,start)
	if start == nil then start=1 end
	local value = {}
	local idx = start

	skip_char(text,idx,"{")
	idx = idx+1
	if text:sub(idx,idx)=="}" then return start,idx,value end
	local s, t, v = decode_string(text,idx)
	idx = t + 1
	skip_char(text,idx,":")
	idx = idx+1
	local key = v

	
	s, t, v = decode_value(text,idx)
	idx = t+1
	local val = v
	value[key] = val
	if text:sub(idx,idx) == "}" then return start,idx,value end

	while true do
		if text:sub(idx,idx) ~= "," then break end
		idx = idx+1

		local s,t,v = decode_string(text,idx)
		idx = t + 1
		skip_char(text,idx,":")
		idx = idx + 1
		local  key = v

		s, t, v = decode_value(text,idx)
		idx = t+1
		local val = v
		value[key] = val
	end
	skip_char(text,idx,"}")

	return start,idx,value

end


function M.decode_arrary(text,start)
	if start == nil then start=1 end
	local value = {}
	local idx = start

	skip_char(text,idx,"[")
	idx = idx + 1
	if text:sub(idx,idx) == "]" then return start,idx,value end

	local s,t,v = decode_value(text,idx)
	table.insert(value,v)
	idx = t+1
	-- if text:sub(idx,idx) == "]" then
	-- 	return start,idx,value
	-- end

	while true do
		if text:sub(idx,idx) ~= "," then break end
		idx = idx+1

		local s,t,v = decode_value(text,idx)
		table.insert(value,v)
		idx = t + 1
	end

	skip_char(text,idx,"]")

	--print(start,idx,#text)

	return start,idx,value
end




function M.loads(json_str)
	local s,t,v = decode_value(json_str)
	if t ~= #json_str then
		error("loads json error:expect len:"..#json_str.." got "..t)
	end
	return v 
end

function M.dumps(json_table)
	local json_str
end




--------------------------for test------------------------------------------
require("utils")
local function _test_decode_number(input_text,true_value)
	local s, t, value = decode_number(input_text)
	assert(value==true_value,"test_decode_error:"..input_text.."->"..true_value)
end

local function test_decode_number()

	_test_decode_number("0",0)
	_test_decode_number("-0",0)
	_test_decode_number("+0",0)
	_test_decode_number("00000",0)
	_test_decode_number("-0.11111",-0.11111)
	_test_decode_number("+0.132132321",0.132132321)
	_test_decode_number("12321321321321",12321321321321)
	_test_decode_number("132131.321321",132131.321321)
	_test_decode_number("+123213",123213)
	_test_decode_number("-123123",-123123)
	_test_decode_number("100e100",100e100)
	_test_decode_number("-100e+10",-100e+10)
	_test_decode_number("+100e-10",100e-10)
	_test_decode_number("-13213.222e+111",-13213.222e111)
	_test_decode_number("-123.321e-100xxx",-123.321e-100)
	_test_decode_number("-123.321",-123.321)
	_test_decode_number("123e1232",123e123)
end

--test_decode_number()

local function test_decode_string( )

	print(decode_string('"xx哈哈\\"xxx"'))
	local text = io.open("test_str.txt","rb"):read("*all")
	print(decode_string(text))

	print("---------test uft8 unicode.------")
	print(utf8_to_unicode("你"))
	print(unicode_to_utf8("0x4f60"))

	local s=unicode_to_utf8("0x81")
	print(utf8_to_unicode(s))

end

-- test_decode_string()

-- -- _,_,a=decode_value('[]')
-- -- print_ext(a)
-- -- _,_,a=M.decode_arrary('[123,["123","efg"]],"abc"]',1)
-- -- print_ext(a)

-- a=M.loads('{}')
-- print_ext(a)

-- print("==================")
-- a=M.loads('{"123":"2\\t13\\"","abc":[1,3,4],"e":{"a":1,"b":"\\u4f60"}}')

-- print_ext(a)


return M