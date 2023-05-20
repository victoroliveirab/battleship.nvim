local Board = require("battleship.boards")

---@class AttackBoard: Board
---@field opposite DefenseBoard
local AttackBoard = {
    opposite = {},
}
setmetatable(AttackBoard, { __index = Board })

---Creates a new instance of a attack board
---@return Board
function AttackBoard:new(opts)
    local instance = Board:new(vim.tbl_extend("force", opts, { empty = true }))
    setmetatable(instance, { __index = AttackBoard })
    return instance
end

---Set defense board counterpart
---@param board DefenseBoard
---@return nil
function AttackBoard:set_opposite(board)
    self.opposite = board
end

---Makes a guess from the attack board on the defense board counterpart
---@param point Point
---@return HitStatus | false
function AttackBoard:guess(point)
    local row = point.row
    local col = point.col_index
    local spot = self.state[row][col]
    if spot ~= "." then -- Spot already hit
        return false
    end
    local status = self.opposite:hit(row, col)
    self.state[row][col] = status.hit == 0 and "~" or tostring(status.hit)
    return status
end

return AttackBoard
