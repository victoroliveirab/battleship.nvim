local Game = require("battleship.loop")
print("Hello from '/plugin/init.lua' in battleship")

vim.api.nvim_create_user_command("Battleship", function()
    require("battleship").setup()
    local game = Game:new()
    game:start()
end, { desc = "Start a new game of Battleship with default settings" })
