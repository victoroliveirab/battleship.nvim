local utils = require("battleship.utils")

local pathname =
    string.format("%s/battleship-stats.txt", vim.api.nvim_call_function("stdpath", { "data" }))

local Stats = {}

---@class Stats
---@field played integer
---@field abandoned integer
---@field wins integer
---@field losses integer
local game_stats = {
    played = 0,
    abandoned = 0,
    wins = 0,
    losses = 0,
}

Stats.init = function()
    local file = io.open(pathname, "r")
    if not file then
        local new_file = io.open(pathname, "w")
        if not new_file then
            return
        end
        local content = ""
        for key in pairs(game_stats) do
            content = string.format("%s%s:%d\n", content, key, 0)
        end
        new_file:write(content)
        return
    end

    while true do
        local line = file:read()
        if not line then
            break
        end
        local str_iterator = utils.split(line, ":", true)
        local key = str_iterator()
        if key and game_stats[key] then
            game_stats[key] = tonumber(str_iterator())
        end
    end
    file:close()
end

Stats.get = function()
    return game_stats
end

---@param key string
Stats.increment = function(key)
    game_stats[key] = game_stats[key] + 1
end

Stats.save = function()
    local content = ""
    for key, value in pairs(game_stats) do
        content = string.format("%s%s:%d\n", content, key, value)
    end
    local file = io.open(pathname, "w+")
    if not file then
        error("Error while saving statistics", 2)
    end
    file:write(content)
    file:close()
end

return Stats
