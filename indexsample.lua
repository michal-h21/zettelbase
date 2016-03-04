local index = require "zettelbase.inverted_index"

local tokenizer = require "zettelbase.tokenizer"
local tokenize = tokenizer.tokenize
local tokenstr = tokenizer.tokenstr
local lowerstr = tokenizer.lowerstr
local unaccstr = tokenizer.unaccentedstr
local get_variants = tokenizer.get_variants

local tokens = {}
local count = 0
local function add_token(str)
  local i = tokens[str] or 0
  i = i + 1
  tokens[str] = i
end

local indexdb = {}
local function adddoc(docid, token, data)
  local docs = indexdb[token] or {}
  docs[docid] = data
  indexdb[token] = docs
end

local ulower = unicode.utf8.lower


local docid = 0
for line in io.lines() do
  docid = docid + 1
  local doctokens = {}
  local count = 0 
  i = 0
  for _, token in ipairs(tokenize(line)) do
    -- local str = tokenstr(token)
    -- local lstr, is_upper = lowerstr(token)
    -- add_token(str)
    -- if is_upper then
    --   add_token(lstr)
    -- end
    -- local unaccstr, is_acc = unaccstr(token)
    -- if is_acc then
    --   add_token(unaccstr)
    --   if is_upper then
    --     add_token(ulower(unaccstr))
    --   end
    -- end
    for _,t in ipairs(get_variants(token)) do
      add_token(t)
      doctokens[t] = true
    end
    count = count + 1
  end
  for k,_ in pairs(doctokens) do
    adddoc(docid, k, tokens[k] / count)
  end
  
end

local db = {}
for str, c in pairs(tokens) do
  index.add_word(db, str)
  -- print(str)
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
local search = arg[1] or "pit"
local pitt = index.find_word(db,search)


for _, word in ipairs(pitt) do
  local t = {}
  for k, v in pairs(indexdb[word] or {}) do
    t[#t+1] = k
  end
  print(word, table.concat(t, ","))
end

-- for word, documents in pairs(indexdb) 

print(collectgarbage("count")*1024)
