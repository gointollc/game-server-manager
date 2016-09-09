# game-server-manager
Application to track operating game servers and provide an up to date and healthy list.  As well as make cluster adjustments if necessary

## Installation

1. Copy config.lua.tpl to config.lua and adjust the configuration as necessary.
2. `lapis build production`
3. `lapis server production`

## Ping

Pinging the server is what lets the tracker know that a server is active and what kind of room it has.  It also lets the tracker know that the server is still alive.  if it doesn't get a ping before `server_timeout` is reached, it will be considered dead and removed from the list. 

### Ping POST Fields 

- `psk` - The pre-shared key used for authentication of game servers.
- `port` - The UDP port the server is listening on.
- `hostname` - The hostname clients can use to connect to the server.
- `name` - The public name or 'title' of the server.
- `maxPlayers` - Maximum players that can connect to the server.
- `activePlayers` - Current active players connected to the server.