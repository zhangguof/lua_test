-- test_json.lua
require("utils")
local  json = require("json")

s='{"a":1,"b":2}'
-- print_ext(json.loads(s))

text = io.open("test_str.txt","rb"):read("*all")
print(text)
print_ext(json.loads(text))
