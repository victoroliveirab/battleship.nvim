local Board = require("battleship.boards")

---@class DefenseBoard
---@field state BoardState
---@field hits number[]
local DefenseBoard = {}
setmetatable(DefenseBoard, { __index = Board })

function DefenseBoard:new(opts)
    local instance = Board:new(vim.tbl_extend("force", opts, { empty = false }))
    instance = vim.tbl_extend("force", instance, {
        hits = { 0, 0, 0, 0, 0 },
    })
    setmetatable(instance, { __index = DefenseBoard })
    return instance
end

---@class HitStatus
---@field hit 0 if miss or ship length if hit
---@field destroyed boolean Whether spot was the last piece of a ship
---@field game_over boolean Whether hit resulted in a game over

---Receives a hit
---@param row string
---@param col number
---@return HitStatus
function DefenseBoard:hit(row, col)
    local return_tbl = {
        hit = 0,
        destroyed = false,
        game_over = false,
    }
    local spot = self.state[row][col]
    if spot == "." then
        return return_tbl
    end
    local ship = assert(tonumber(spot))
    return_tbl.hit = ship
    self.hits[ship] = self.hits[ship] + 1
    if self.hits[ship] == ship then
        return_tbl.destroyed = true
    end
    return_tbl.game_over = self:check_game_over()
    return return_tbl
end

function DefenseBoard:check_game_over()
    for index, value in ipairs(self.hits) do
        if index > 1 and index > value then
            return false
        end
    end
    return true
end

return DefenseBoard
