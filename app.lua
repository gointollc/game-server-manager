--[[
    Copyright (C) 2016 GoInto, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]
local lapis = require("lapis")
local app_helpers = require("lapis.application")
local validate = require("lapis.validate")
local config = require("lapis.config").get()
local rover = require("mongorover")
local client = rover.MongoClient.new("mongodb://localhost:27017/")
local database = client:getDatabase("gsm")
local server_collection = database:getCollection("servers")
local mp = require("MessagePack")
local ngx = require("ngx")

--local redis_client = redis.connect('127.0.0.1', 6379)
local app = lapis.Application()
local capture_errors = app_helpers.capture_errors

app.handle_error = function(self, err, trace)
    ngx.log(ngx.NOTICE, "There was an error! " .. err .. ": " ..trace)
    return { json = { error = err, trace = trace } }
end

app:enable("etlua")

app:get("/", function()

    app.layout = require "views.layout"

    if config.company then
        page_title = (config.company .. " Server Tracker")
    end
    
    email = config.email

    return { 
        render = "index"
    }

end)

app:get("/robots.txt", function() 
    return { render = "robots" }
end)

app:get("/server", function(self) 

    local clock = os.time()
    local timediff = clock - config.server_timeout

    local showDevServers = false
    if self.params.dev then
        showDevServers = true
    end
    
    local result_servers = server_collection:find({ ping = { ["$gt"] = timediff }, dev = showDevServers })
    
    local servers = {}
    for server in result_servers do
        if self.params.dev then
            table.insert(servers, server)
        else
            table.insert(servers, {
                hostname = server['hostname'],
                port = server['port'],
                name = server['name'],
                activePlayers = server['activePlayers'],
                maxPlayers = server['maxPlayers'],
                ping = server['ping'],
            })
        end
    end

    return { 
        json = { 
            servers = servers
        },
        content_type = "application/json" 
    }

end)

app:post("/server", function() 
    return { redirect_to = "/" }
end)

-- TODO: app:delete("/server/ping")

app:post("/server/ping", capture_errors({
    function(self)

        local success
        local reason
        
        ngx.log(ngx.NOTICE, "PSK: " .. self.params.psk)
        ngx.log(ngx.NOTICE, "hostname: " .. self.params.hostname)
        ngx.log(ngx.NOTICE, "port: " .. self.params.port)
        ngx.log(ngx.NOTICE, "name: " .. self.params.name)
        ngx.log(ngx.NOTICE, "ping: " .. os.date("%Y-%m-%d %H:%M:%S"))

        validate.assert_valid(self.params, {
            { "psk", exists = true, "Authentication failed" },
            { "name", exists = true, "Server name not proided." },
            { "hostname", exists = true, "Hostname not proided." },
            { "port", exists = true, "Port not proided." },
        }) 

        -- authenticate
        if self.params.psk ~= config.production_psk and self.params.psk ~= config.development_psk then 
            return {
                json = {
                    success = false, 
                    reason = "Authentication failure"
                },
                content_type = "application/json"
            }
        end

        -- If activePlayers wasn't defined, let's assume there was none
        local activePlayers
        if self.params.activePlayers then
            activePlayers = self.params.activePlayers
        else
            activePlayers = 0
        end

        -- If maxPlayers wasn't defined, let's default to 4
        local maxPlayers
        if self.params.maxPlayers then
            maxPlayers = self.params.maxPlayers
        else
            maxPlayers = 4
        end

        -- Is this server a development server? We're going to decide by
        -- using the PSK.  There's one for prod and another for dev
        local dev
        if self.params.psk == config.production_psk then
            dev = false
        else 
            dev = true 
        end

        -- define the document we're going to put in mongo
        local server_doc = { 
            name = self.params.name, 
            ping = os.time(),
            activePlayers = tonumber(activePlayers),
            maxPlayers = tonumber(maxPlayers), 
            dev = dev,
        }

        -- update mongo
        local result = server_collection:update_one(
            { hostname = self.params.hostname, port = self.params.port },
            {["$set"] = server_doc},
            true
        )

        if result.matched_count > 0 then

            success = true
            reason = "Successfully added server"

        else

            success = false 
            reason = "Could not add server"

        end

        return {
            json = {
                success = success, 
                reason = reason
            },
            content_type = "application/json"
        }

    end,
    on_error = function(self, err, trace)
        --ngx.log(ngx.NOTICE, "There was an error! " .. self.errors[0])
        return { 
            json = {
                success = false, 
                reason = self.errors
            },
            content_type = "application/json" 
        }
    end
}))

return app
