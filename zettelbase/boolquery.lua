local lpeg = require "lpeg"


local function prepare(t1) 
  local t = {}
  for _, v in ipairs(t1) do
    t[v] = true
  end
  return t
end

local set1 = {11, 22, 33, 43, 22, 55, 63}

local set2 = {11, 44, 43, 66, 55}
set1 = prepare(set1)
set2 = prepare(set2)

local AND = function(t1, t2)
  local t = {}
  for k,v in pairs(t1) do
    if t2[k] then
      t[k] = v
    end
  end
  return t
end

local OR = function(t1, t2)
  local t = {}
  for k,v in pairs(t1) do
    t[k] = v
  end
  for k,v in pairs(t2) do
    t[k] = v
  end
  return t
end

local XOR = function(t1, t2) 
  local t = {}
  for k,v in pairs(t1) do
    if not t2[k] then t[k] = v end
  end
  for k,v in pairs(t2) do
    if t1[k] then 
      -- remove the key if it is contained in the first table
      t[k] = nil 
    else
      t[k] = v
    end
  end
  return t
end

local NOT = function(t1, t2)
  local t = {}
  for k,v in pairs(t1) do t[k] = v end
  for k,v in pairs(t2) do
    if t[k] then t[k] = nil end
  end
  return t
end



local printset = function(t1)
  local t = {}
  for k, v in pairs(t1) do
    t[#t+1] = k
  end
  table.sort(t)
  print(table.concat(t, ","))
end

printset(set1)
printset(set2)
printset(AND(set1,set2))
printset(OR(set1, set2))
printset(XOR(set1, set2))
printset(OR(NOT(set1, set2), NOT(set2, set1)))
printset(NOT(set1,set2))


local P = lpeg.P
local C = lpeg.C
local S = lpeg.S
local Ct= lpeg.Ct
local white = S(" \t\n\r") ^ 0

local char = P(1)
local text = Ct(char ^ 1)
local extract = white * text 

for k, v in pairs(text:match "helllo world") do
  print(k,v)
end
