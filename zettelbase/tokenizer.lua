local M = {}

local unicode = unicode or require "unicode"

local sub = unicode.utf8.sub
local ubyte = unicode.utf8.byte

local categories = {
  {0,  "controll"},
  {48, "numbers"},
  {58, "controll"},
  {65, "letters"},
  {91, "controll"},
  {97, "letters"},
  {123, "controll"},
  {0x00C0, "letters"},
}
local memoized_categories = {}
local function get_category(char)
  if memoized_categories[char] then return memoized_categories[char] end
  local category = ""
  local charcode = ubyte(char)
  for _, c in ipairs(categories) do
    if charcode < c[1] then break end
    category = c[2]
  end
  memoized_categories[char] = category
  -- print(char, category)
  return category
end


local function token_stream(stream, tokens, pos)
  local tokens = tokens or {}
  local pos = pos or 1
  if pos > #stream then return tokens end
  local curr = curr or {}
  local currobj = stream[pos] or {}
  while currobj.category == "letters" and pos <= #stream do
    curr[#curr + 1] = currobj.char
    pos = pos + 1
    currobj = stream[pos] or {}
  end
  if #curr > 0 then
    tokens[#tokens + 1] = table.concat(curr) 
  else
    pos = pos + 1
  end
  return token_stream(stream, tokens, pos )
end

  

local tokenize = function(str)
  local tokens = {}
  local current = {}
  local pos = 1
  local char = sub(str, pos, 1)
  local stream = {}
  while(char ~= "" ) do
    local category = get_category(char)
    stream[#stream + 1] = {char = char, category = category}
    pos = pos + 1
    char = sub(str, pos, pos )
  end
  tokens = token_stream(stream)
  return tokens
end

local tokens = tokenize "nazdar 'světe', příliš? (žluťoučký) @kůň"
for k,v in ipairs(tokens) do
  print(k,v)
end
M.tokenize = tokenize
return M
