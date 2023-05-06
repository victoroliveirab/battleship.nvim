local Board = require("battleship.boards")

---@class AttackBoard
---@field state BoardState
---@field opposite DefenseBoard
local AttackBoard = {
    opposite = {},
}
setmetatable(AttackBoard, { __index = Board })

function AttackBoard:new(opts)
    local instance = Board:new(vim.tbl_extend("force", opts, { empty = true }))
    setmetatable(instance, { __index = AttackBoard })
    return instance
end

---Set defense board counterpart
---@param board DefenseBoard
function Board:set_opposite(board)
    self.opposite = board
    return self
end

---Makes a guess from the attack board on the defense board counterpart
---@param row string
---@param col number
---@return HitStatus | false
function AttackBoard:guess(row, col)
    local spot = self.state[row][col]
    if spot == "." then
        return self.opposite:hit(row, col)
    else
        print("Spot already chosen before")
        return false
    end
end

return AttackBoard
