-- config.lua
local config = require("lapis.config")

config("development", {
    psk = "AFDLKMosidmflaskdmflSKLDKSLDFMlksa",
    port = 9000,
    company = "GoInto Games",
    url = "https://gointo.software",
    email = "hostmaster@gointo.software",
    server_timeout = 60 * 6
})