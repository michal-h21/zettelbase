local controller = {}

-- https://github.com/APItools/router.lua
local router  = require "router"
-- database object
local model   = {}

local routobj = router.new()

function controller.setModel(m)
  model = m
end

-- interface to methods provided by router.lua 
function controller.get(path, fn)
  return routobj:get(path, fn)
end

function controller.post(path, fn)
  return routobj:post(path, fn)
end

function controller.put(path, fn)
  return routobj:put(path, fn)
end

function controller.delete(path, fn)
  return routobj:delete(path, fn)
end

function controller.match(obj)
  return routobj:match(obj)
end

-- execute the controller
-- response and request are tables provided by pegasus
function controller.run(request, response, params)
  local params      = params or {}
  local request     = request or {}
  params._model     = model
  params._request   = request
  params._response  = response
  local method      = request:method()
  local path        = request:path()
  return routobj:execute(method, path, params)
end

return controller
