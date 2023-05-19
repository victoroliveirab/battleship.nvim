local BaseAI = require("battleship.ais")
local ai_helpers = require("battleship.ais.helpers")

---@class EasyAI: CpuAI
local EasyAI = {}
setmetatable(EasyAI, { __index = BaseAI })

---Creates a new AI of difficulty easy
---@param options { board: Board }
function EasyAI:new(options)
    local instance = BaseAI:new(options)
    setmetatable(instance, { __index = EasyAI })
    return instance
end

---@return Coordinates
function EasyAI:next_move()
    return ai_helpers.get_random_point()
end

return EasyAI
