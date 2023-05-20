local utils = require("battleship.utils")
---@class CpuAI
---@field board AttackBoard
---@field lower_end Point? One end of the current hit ship
---@field upper_end Point? Other end of the current hit ship
---@field hits Point? Tracks hits in current situation
---@field misses Point? Tracks misses in current situation
local BaseAI = {
    board = {},
    lower_end = nil,
    upper_end = nil,
    hits = nil,
    misses = nil,
}
BaseAI.__index = BaseAI

---Creates a new AI
---@param options { board: Board }
function BaseAI:new(options)
    return setmetatable({ board = options.board }, self)
end

---Chooses a new spot on the player's board
---@return Coordinates
function BaseAI:next_move()
    error("Should be implemented", 2)
end

---@param point Point
---@param status HitStatus
function BaseAI:mark_hit(point, status)
    local first_hit = not utils.toboolean(self.lower_end)
    if first_hit then
        self.lower_end = point
        self.upper_end = nil
        self.hits = { point }
        self.misses = {}
        return
    end

    table.insert(self.hits, point)
    local second_hit = not utils.toboolean(self.upper_end)
    if second_hit then
        ---@type Point
        local first_point = self.lower_end
        local is_vertical = point.col == first_point.col
        if is_vertical then
            local is_second_hit_above = point.row:byte() - first_point.row:byte() < 0
            local is_second_hit_below = not is_second_hit_above
            self.lower_end = is_second_hit_above and point or first_point
            self.upper_end = is_second_hit_below and point or first_point
        else
            local is_second_hit_on_the_left = point.col < first_point.col
            local is_second_hit_on_the_right = not is_second_hit_on_the_left
            self.lower_end = is_second_hit_on_the_left and point or first_point
            self.upper_end = is_second_hit_on_the_right and point or first_point
        end
        return
    end
end

function BaseAI:mark_miss(point)
    if self.misses then
        table.insert(self.misses, point)
    end
end

function BaseAI:mark_destroyed()
    self.lower_end = nil
    self.upper_end = nil
    self.hits = nil
    self.misses = nil
end

---Updates the direction in which the AI should make the next guess
---@param direction "x"|"y"
---@return nil
function BaseAI:update_direction(direction)
    self.direction = direction
end

return BaseAI
