local Game = require("battleship.loop")
local Stats = require("battleship.stats")

vim.api.nvim_create_user_command("Battleship", function()
    require("battleship").setup({ run_tests = true })
    local game = Game:new()
    Stats.init()
    game:start()
end, { desc = "Start a new game of Battleship with default settings" })
