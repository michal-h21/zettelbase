local index = require "zettelbase.inverted_index"

local tokenizer = require "zettelbase.tokenizer"
local tokenize = tokenizer.tokenize
local tokenstr = tokenizer.tokenstr
local lowerstr = tokenizer.lowerstr
local unaccstr = tokenizer.unaccentedstr

local tokens = {}
local count = 0
local function add_token(str)
  local i = tokens[str] or 0
  i = i + 1
  tokens[str] = i
end
local ulower = unicode.utf8.lower
for line in io.lines() do
  for _, token in ipairs(tokenize(line)) do
    local str = tokenstr(token)
    local lstr, is_upper = lowerstr(token)
    add_token(str)
    if is_upper then
      add_token(lstr)
    end
    local unaccstr, is_acc = unaccstr(token)
    if is_acc then
      add_token(unaccstr)
      if is_upper then
        add_token(ulower(unaccstr))
      end
    end
    count = count + 1
  end
end

local db = {}
for str, c in pairs(tokens) do
  index.add_word(db, str)
  print(str,  c / count)
end
  

for k,v in ipairs {
  "žluna", "rys", "vajíčko", "les", "lesák", "šumava", "lesník", "lesový", "lesa"
} do
  index.add_word(db, v)
end

index.find_word(db, "les")
index.find_word(db, "rys")
index.find_word(db, "rysaddjj")
index.find_word(db, "table")
