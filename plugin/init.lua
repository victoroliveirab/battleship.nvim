local Game = require("battleship.loop")
local constants = require("battleship.constants")

vim.api.nvim_create_user_command("Battleship", function()
    require("battleship").setup()
    local game = Game:new()
    vim.api.nvim_create_autocmd("VimResized", {
        group = constants.BATTLESHIP_AUTO_GROUP,
        callback = function()
            vim.schedule(function()
                game:on_resize()
            end)
        end,
    })
    game:start()
end, { desc = "Start a new game of Battleship with default settings" })
