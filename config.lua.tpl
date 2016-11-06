-- config.lua
local config = require("lapis.config")

config("development", {
    production_psk = "CHANGEMELKMosidmflaskdmflSKLDKSLDFMlksa",
    development_psk = "IMALITTLETEAPOT",
    port = 9000,
    company = "My Company",
    url = "https://gointo.software",
    email = "hostmaster@example.com",
    server_timeout = 60 * 6
})
