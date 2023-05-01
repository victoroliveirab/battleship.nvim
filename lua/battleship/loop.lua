local Board = require("battleship.board")

--- @class Game
--- @field difficulty string
--- @field boards table
--- @field is_player_turn boolean
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
    }
    setmetatable(data, self)
    self.__index = self
    print("Created game")
    return data
end

function Game:start()
    print("Start game")
    print(vim.inspect(self.boards.player))
end

function Game:loop()
    print("Game loop")
end

return Game
