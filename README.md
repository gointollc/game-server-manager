# game-server-manager
Application to track operating game servers and provide an up to date and healthy list.  As well as make cluster adjustments if necessary

## Installation

1. Copy config.lua.tpl to config.lua and adjust the configuration as necessary.
2. `lapis build production`
3. `lapis server production`

## Get servers

*Endpoint*: `/server`
*Accepted Methods*: `GET`

Get all available game servers.

### Example Output

    {
        servers: [
            {
                activePlayers: 2,
                maxPlayers: 4,
                ping: 1478410862,
                name: "US-East-1",
                hostname: "server1.eastus.example.com",
                port: "1234"
            }
        ]
    }

## Ping

Endpoint: `/server/ping`
*Accepted Methods*: `POST`

Pinging the server is what lets the tracker know that a server is active and what kind of room it has.  It also lets the tracker know that the server is still alive.  if it doesn't get a ping before `server_timeout` is reached, it will be considered dead and removed from the list. 

### Ping POST Fields 

- `psk` - The pre-shared key used for authentication of game servers.
- `port` - The UDP port the server is listening on.
- `hostname` - The hostname clients can use to connect to the server.
- `name` - The public name or 'title' of the server.
- `maxPlayers` - Maximum players that can connect to the server.
- `activePlayers` - Current active players connected to the server.
- 'dev' - Whether the server is a development build or not.

### Example Output

    {
        "success": true,
        "reason": "Successfully added server"
    }

## Other Endpoints 

These other minor endpoints exist as well: 

`GET /`: Basic html index for stray browsers

`GET /robots.txt`: [Robots file](http://www.robotstxt.org/) to limit crawlers from grabbing up any information from the API.
