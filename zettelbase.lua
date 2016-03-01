-- setup path to find the project source files of Pegasus
package.path = "./src/?.lua;./src/?/init.lua;"..package.path


-- Example that uses Copas as a socket scheduler, allowing multiple
-- servers to work in parallel.
-- For this example to work with the https version, you need LuaSec
-- to be installed, and you need to generate the test certificates from
-- its examples. Copy the 'A' certificates into this example directory
-- to make it work.
local Handler = require 'pegasus.handler'
local copas = require('copas')
local Compress = require 'pegasus.compress'
local authenticate = require "basic-auth"
local controller = require "zettelbase.controller"

local hdlr = Handler:new(function (req, rep)
    if rep then
      local t = {'hello pegasus world!'}
      for k,v in pairs(req:headers()) do t[#t+1] = k.."\t"..tostring(v) end
      if req._method == "POST" then
        print "POSTR"
        print(req:receiveBody())
        for k,v in pairs(req:post()) do t[#t+1] = k.." - post\t"..tostring(v) end
        for k,v in pairs(req:headers()) do print("head", k, v) end
        t[#t+1] = "post:\t"..tostring(#req:post())
      end
      local auth = authenticate(req)
      rep:addHeader('Content-Type', 'text/html')
      if auth then
        print(auth.name, auth.pass)
      end
      controller.get("/hello/:name", function(params)
         return "controller hello: ".. params.name
      end)
      local status, msg =  controller.run(req, rep)
      if status then
        t[#t+1] = msg
      end
      rep:write(table.concat(t,"\n"))
    end
  end, nil, {Compress:new()})
  -- end, '/root/')


-- Create http server
local server = assert(socket.bind('*', 9090))
local ip, port = server:getsockname()
copas.addserver(server, copas.handler(function(skt)
    hdlr:processRequest(skt)
  end))
print('Pegasus is up on ' .. ip .. ":".. port)


-- Create https server
sslparams = {
   mode = "server",
   protocol = "tlsv1",
   key = "./serverAkey.pem",
   certificate = "./serverA.pem",
   cafile = "./rootA.pem",
   verify = {"peer"},
   options = {"all", "no_sslv2"},
}
local server = assert(socket.bind('*', 8443))
local ip, port = server:getsockname()
copas.addserver(server, copas.handler(function(skt)
    hdlr:processRequest(skt)
  end, sslparams))
print('Pegasus (https) is up on ' .. ip .. ":".. port)

-- Start
copas.loop()
