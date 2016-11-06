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
