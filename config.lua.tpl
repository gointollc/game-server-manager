-- config.lua
local config = require("lapis.config")

config("development", {
    psk = "CHANGEMELKMosidmflaskdmflSKLDKSLDFMlksa",
    port = 9000,
    company = "My Company",
    url = "https://gointo.software",
    email = "hostmaster@example.com",
    server_timeout = 60 * 6
})
