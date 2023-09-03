local constants = require("battleship.constants")

local highlight_groups = {
    PlayerBoardHit = { fg = "#00ff00" },
    PlayerBoardMiss = { fg = "#ff0000" },
    CPUBoardHit = { fg = "#ff0000" },
    CPUBoardMiss = { fg = "#00ff00" },
}

---@class M
---@field configs BattleshipSetupOptions
---@field configs.ships {name: string, size: integer}
local M = {
    configs = {
        ships = {},
    },
}

---@class BattleshipSetupOptions
---@field fast_mode boolean?
---@field seed number?
---@field vdivider string?
---@field hdivider string?
---@field simple_dividers boolean?
---@field ships {[string]: integer}
---@field run_tests boolean? whether it should the test suit

--- Setup function
--- @param options BattleshipSetupOptions?
--- @return nil
M.setup = function(options)
    options = options or {}
    local seed = options.seed or os.time()
    math.randomseed(seed)
    vim.api.nvim_create_augroup(constants.BATTLESHIP_AUTO_GROUP, { clear = true })
    local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)

    for group, hi in pairs(highlight_groups) do
        vim.api.nvim_set_hl(ns, group, hi)
    end

    local vdivider = options.vdivider or constants.CHARS_MAP.PIPE
    local hdivider = options.hdivider or constants.CHARS_MAP.DASH
    local fast_mode = options.fast_mode or false

    local ships = constants.SHIPS
    -- Check if ships total length does not exceed 25 pins AND no ship is larger than 8 pegs
    if options.ships and type(options.ships) == "table" then
        local sum = 0
        for ship_name, ship_size in pairs(options.ships) do
            if ship_size > 8 then
                error("No ship can be larger than 8 pegs. Reduce the size of " .. ship_name, 2)
            end
            sum = sum + ship_size
        end
        if sum > 25 then
            error(
                "No more than 25 pins can be filled by ships. Current number: " .. tostring(sum),
                2
            )
        end
        ships = options.ships
    end
    ---@type {name: string, size: integer}[]
    local ordered_ships = {}
    for ship_name, ship_size in pairs(ships) do
        local index = 1
        while ordered_ships[index] and ordered_ships[index].size > ship_size do
            index = index + 1
        end
        table.insert(ordered_ships, index, { name = ship_name, size = ship_size })
    end

    if options.simple_dividers then
        vdivider = "|"
        hdivider = "-"
    end

    if options.run_tests then
        require("battleship.tests")
    end
    M.configs = {
        fast_mode = fast_mode,
        ships = ordered_ships,
        hdivider = hdivider,
        vdivider = vdivider,
    }
    -- TODO: see how to protect writes on M.configs from now on
    vim.g.battleship_setup = 1
end

return M
