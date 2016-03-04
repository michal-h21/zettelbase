local M = {}

unicode = unicode or require "unicode"
local removeaccents = require "zettelbase.removeaccents"

local sub = unicode.utf8.sub
local ubyte = unicode.utf8.byte
local ulower = unicode.utf8.lower

-- all codepoints between starting number and next one fall into current category
local categories = {
  {0,  "system"},
  {32, "space"},
  {33, "controll"},
  {48, "numbers"},
  {58, "controll"},
  {65, "letters"},
  {91, "controll"},
  {97, "letters"},
  {123, "controll"},
  {0x00C0, "letters"},
  {0x2000, "controll"},
  {0x2070, "letters"}
}
local memoized_categories = {}
local function get_category(char)
  if memoized_categories[char] then return memoized_categories[char] end
  local category = ""
  local charcode = ubyte(char)
  -- search categories table for the letter
  for _, c in ipairs(categories) do
    -- c[1] is the start of current codepoint range
    -- if the current codepoint is lower, it falls into previous range
    if charcode < c[1] then break end
    category = c[2]
  end
  memoized_categories[char] = category
  -- print(char, category)
  return category
end

local inwords = {["."] = "", ["'"] = "'"}

-- we need to fix things like "don't", "F.B.I." etc 
local function prepare_token_stream(stream)
  for i, v in ipairs(stream) do
    local current = stream[i]
    if current.category == "controll" then
      local prev = stream[i - 1] or {}
      local next = stream[i + 1] or {}
      if prev.category == "letters" and next.category == "letters" and inwords[current.char]  then
        current.category = "letters"
        current.char = inwords[current.char]
      end
    end
  end
  return stream
end


-- process the token stream -- words are consecutive letter objects
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
    tokens[#tokens + 1] = curr--table.concat(curr) 
  else
    pos = pos + 1
  end
  return token_stream(stream, tokens, pos )
end

-- token to string functions
-- return converted string, contains uppercase?: boolean
function M.lowerstr(tokens)  
  local str = table.concat(tokens)
  local low = ulower(str)
  return str, str == low
end

-- convert tokens to plain strin
function M.tokenstr(tokens)
  return table.concat(tokens)
end

function M.unaccentedstr(tokens)
  local tokens, status = removeaccents.strip_accents(tokens)
  return table.concat(tokens), status
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
  stream = prepare_token_stream(stream)
  -- tokens is table with character subarrays
  tokens = token_stream(stream)
  return tokens
end

-- local tokens = tokenize "nazdar 'světe', příliš? (žluťoučký) @kůň"
-- for k,v in ipairs(tokens) do
--   print(k,v)
-- end
M.tokenize = tokenize
return M
