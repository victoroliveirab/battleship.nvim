local BaseAI = require("battleship.ais")
local utils = require("battleship.utils")

local ai_helpers = require("battleship.ais.helpers")
local constants = require("battleship.constants")

---@class MediumAI: CpuAI
local MediumAI = {}
setmetatable(MediumAI, { __index = BaseAI })

---Creates a new AI of difficulty easy
---@param options { board: Board }
function MediumAI:new(options)
    local instance = BaseAI:new(options)
    setmetatable(instance, { __index = MediumAI })
    return instance
end

---@return Coordinates
function MediumAI:next_move()
    if self.lower_end then
        return self:_attack_found()
    end
    return ai_helpers.get_random_point()
end

---@return Coordinates
function MediumAI:_attack_found()
    return ai_helpers.get_random_point()
end

return MediumAI
