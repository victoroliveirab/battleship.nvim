local constants = require("battleship.constants")

local M = {}

--- @class BattleshipSetupOptions
--- @field seed number

--- Setup function
--- @param options BattleshipSetupOptions?
M.setup = function(options)
    options = options or {}
    local seed = options.seed or os.time()
    math.randomseed(seed)
    print("Setup of battleship.nvim seed: " .. tostring(seed))
    vim.api.nvim_create_augroup(constants.BATTLESHIP_AUTO_GROUP, { clear = true })
end

return M
