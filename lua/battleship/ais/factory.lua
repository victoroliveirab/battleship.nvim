local EasyAI = require("battleship.ais.easy")
local MediumAI = require("battleship.ais.medium")

---Creates an AI instance
---@param difficulty "easy" | "medium"
---@param board Board
---@return CpuAI
return function(difficulty, board)
    if difficulty == "easy" then
        return EasyAI:new({ board = board })
    end

    if difficulty == "medium" then
        return MediumAI:new({ board = board })
    end

    error("Difficulty " .. difficulty .. " not implemented", 2)
end
