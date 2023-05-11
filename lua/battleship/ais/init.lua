---@class CpuAI
---@field board AttackBoard
local BaseAI = {
    board = {},
}
BaseAI.__index = BaseAI

---Creates a new AI
---@param options { board: Board }
function BaseAI:new(options)
    return setmetatable({ board = options.board }, self)
end

---Attacks a new spot on the player's board
---@return Coordinates
function BaseAI:attack()
    error("Should be implemented", 2)
end

return BaseAI
