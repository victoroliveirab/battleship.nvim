local BaseAI = require("battleship.ais")
local constants = require("battleship.constants")

---@class EasyAI: CpuAI
local EasyAI = {}
setmetatable(EasyAI, { __index = BaseAI })

---@return Coordinates
function EasyAI:attack()
    local row = constants.BOARD_ROWS[math.random(1, 10)]
    local col = math.random(1, 10)
    return {
        row = row,
        col = col,
    }
end

return EasyAI
