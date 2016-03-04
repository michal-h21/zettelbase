-- 
--
--
unicode = unicode or require "unicode"
local M = {}
local index = {
  documents = {},
  words = {}

}

local sub = unicode.utf8.sub

local function make_chars(word, chars)
  local chars = chars or {}
  if word == "" then return chars end
  local first = sub(word, 1, 1)
  local rest = sub(word, 2)
  chars[#chars + 1] = first 
  return make_chars(rest, chars)
end

-- insert word to word DB
function M.add_word(db, word)
  local db = db or {}
  local chars = make_chars(word)
  -- print(word)
  -- if word == ""  then return db end
  local function add(curr, chars, pos)
    local curr = curr or db
    local pos = pos or 1
    local char = chars[pos] 
    if not char then 
      curr["$"] = {} 
      return
    end
    curr[char] = curr[char] or {}
    -- print(string.rep(" ", pos ) .. char)
    add(curr[char], chars, pos + 1)
  end
  add(db, chars)
  return db
    -- print(first,rest) 
  -- M.add_word(db, rest)
end

local function print_db(db, level)
  local level = level or 0
  for k,v in pairs(db) do
    print(string.rep(" ", level) .. k)
    print_db(v, level + 1)
  end
end

function M.find_word(db, word)
  local chars = make_chars(word)
  local function get_suffixes(chars, suffixes, pos)
    local pos = pos or 1
    local char = chars[pos]
    if not char then return suffixes end
    local suffixes = suffixes or db
    suffixes = suffixes[char]
    -- print("find", char, suffixes)
    if not suffixes then return nil end
    return get_suffixes(chars, suffixes, pos + 1)
  end
  local function get_words(suffixes, words, chars)
    local words = words or {}
    local chars = chars or ""
    local suffixes = suffixes or {}
    if suffixes["$"] then
      table.insert(words, chars)
    end
    for ch, subtable in pairs(suffixes) do
      words = get_words(subtable, words, chars .. ch)
    end
    return words
  end
  local suffixes = get_suffixes(chars)
  local words = get_words(suffixes)
  for k, v in pairs(words) do
    print(word,v)
  end
  return words
end


-- print_db(db)
--
return M
