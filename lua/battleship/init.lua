local constants = require("battleship.constants")

local highlight_groups = {
    PlayerBoardHit = { fg = "#00ff00" },
    PlayerBoardMiss = { fg = "#ff0000" },
    CPUBoardHit = { fg = "#ff0000" },
    CPUBoardMiss = { fg = "#00ff00" },
}

local M = {}

--- @class BattleshipSetupOptions
--- @field seed number

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
end

return M
