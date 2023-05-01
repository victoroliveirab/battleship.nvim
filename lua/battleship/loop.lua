local Board = require("battleship.board")
local BoardUI = require("battleship.ui.board")
local PromptUI = require("battleship.ui.prompt")

local constants = require("battleship.constants")

--- @class Game
--- @field difficulty string
--- @field boards table
--- @field is_player_turn boolean
--- @field ui table
local Game = {}

--- @class GameOptions
--- @field difficulty string?

--- Creates a new game
--- @param options table?
--- @return Game
function Game:new(options)
    options = options or {}
    local difficulty = options.difficulty or "medium"
    local data = {
        difficulty = difficulty,
        boards = {
            player = Board:new("Your Board"),
            cpu = Board:new("CPU's Board"),
            player_attack = Board:new("Attack Board", true),
        },
        is_player_turn = true,
        ui = {
            board = BoardUI:new(constants.UI.BOARD_DEFAULT_OPTS),
            prompt = PromptUI:new(constants.UI.PROMPT_DEFAULT_OPTS),
        },
    }
    setmetatable(data, self)
    self.__index = self
    print("Created game")
    return data
end

function Game:start()
    self.ui.board:show()
    self.ui.prompt:show()

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = self.ui.prompt.buf,
        callback = function()
            self:close()
            return true
        end,
    })

    self:loop()
end

function Game:loop()
    if self.is_player_turn then
        print("Player time")
    else
        print("CPU time")
    end
end

function Game:close()
    local board_ui = self.ui.board
    local prompt_ui = self.ui.prompt

    vim.api.nvim_win_close(board_ui.win, true)
    vim.api.nvim_win_close(prompt_ui.win, true)
    vim.api.nvim_buf_delete(board_ui.buf, { force = true })
    vim.api.nvim_buf_delete(prompt_ui.buf, { force = true })
end

return Game
