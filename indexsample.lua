local index = require "zettelbase.inverted_index"

local tokenizer = require "zettelbase.tokenizer"
local tokenize = tokenizer.tokenize

local tokens = {}
local count = 0
for line in io.lines() do
  for _, token in ipairs(tokenize(line)) do
    local i = tokens[token] or 0
    i = i + 1
    tokens[token] = i
    count = count + 1
  end
end

local db = {}
for token, c in pairs(tokens) do
  index.add_word(db, token)
  print(token, c / count)
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
