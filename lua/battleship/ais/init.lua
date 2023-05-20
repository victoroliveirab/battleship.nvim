local utils = require("battleship.utils")
---@class CpuAI
---@field board AttackBoard
---@field lower_end Point? One end of the current hit ship
---@field upper_end Point? Other end of the current hit ship
---@field hits Point? Tracks hits in current situation
---@field misses Point? Tracks misses in current situation
---@field direction "x"|"y"|nil
local BaseAI = {
    board = {},
    lower_end = nil,
    upper_end = nil,
    hits = nil,
    misses = nil,
    direction = nil,
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
function BaseAI:mark_hit(point)
    local first_hit = not utils.toboolean(self.lower_end)
    if first_hit then
        self.lower_end = point
        self.upper_end = nil
        self.hits = { point }
        self.misses = {}
        self.direction = nil
        return
    end

    table.insert(self.hits, point)
    local is_second_hit = not utils.toboolean(self.upper_end)
    if is_second_hit then
        ---@type Point
        local first_point = self.lower_end
        local is_vertical = point.col == first_point.col
        self:update_direction(is_vertical and "y" or "x")
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

    if self.direction == "x" then
        local is_new_hit_on_lower_end_left = point.col < self.lower_end.col
        local is_new_hit_on_upper_end_right = point.col > self.upper_end.col
        if is_new_hit_on_lower_end_left then
            self.lower_end = point
        end
        if is_new_hit_on_upper_end_right then
            self.upper_end = point
        end
        return
    end

    if self.direction == "y" then
        local is_new_hit_above_lower_end = point.row_index < self.lower_end.row_index
        local is_new_hit_below_upper_end = point.row_index > self.upper_end.row_index
        if is_new_hit_above_lower_end then
            self.lower_end = point
        end
        if is_new_hit_below_upper_end then
            self.upper_end = point
        end
        return
    end

    error("Direction should be set by this moment", 2)
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
    self.direction = nil
end

---Updates the direction in which the AI should make the next guess
---@param direction "x"|"y"
---@return nil
function BaseAI:update_direction(direction)
    self.direction = direction
end

return BaseAI
