local os = require("os")
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

app:get("/server", function() 

    local clock = os.time()
    local timediff = clock - config.server_timeout

    local result_servers = server_collection:find({ ping = { ["$gt"] = timediff }})
    
    local servers = {}
    for server in result_servers do
        table.insert(servers, server)
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

app:get("/server/add", function() 
    return { redirect_to = "/" }
end)

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
        if self.params.psk ~= config.psk then 
            return {
                json = {
                    success = false, 
                    reason = "Authentication failure"
                },
                content_type = "application/json"
            }
        end

        local result = server_collection:update_one(
            { hostname = self.params.hostname, port = self.params.port },
            {["$set"] = { 
                name = self.params.name, 
                ping = os.time(),
                activePlayers = self.params.activePlayers,
                maxPlayers = self.params.maxPlayers, 
            }},
            true
        )

        print(result.matched_count)
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
