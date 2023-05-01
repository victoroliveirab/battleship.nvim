--- @class Game
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
    }
    setmetatable(data, self)
    self.__index = self
    print("Created game")
    return data
end

function Game:start()
    print("Start game")
end

function Game:loop()
    print("Game loop")
end

return Game
