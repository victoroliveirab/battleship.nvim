local BaseAI = require("battleship.ais")
local Point = require("battleship.boards.point")
local utils = require("battleship.utils")

local ai_helpers = require("battleship.ais.helpers")

---@class MediumAI: CpuAI
local MediumAI = {}
setmetatable(MediumAI, { __index = BaseAI })

--- TODO:
--- create some sort of cache in case the ai hits a different boat
--- when seeking another one

---Creates a new AI of difficulty medium
---@param options { board: Board }
function MediumAI:new(options)
    local instance = BaseAI:new(options)
    setmetatable(instance, { __index = MediumAI })
    return instance
end

---@return Coordinates
function MediumAI:next_move()
    if not self.lower_end then
        return ai_helpers.get_random_point()
    end
    if not self.upper_end then
        return self:_seek_second_hit()
    end

    ---@type Point, Point, "x"|"y"
    local lower_end, upper_end, direction = self.lower_end, self.upper_end, self.direction
    local direction_equality_fn = direction == "x" and Point.are_same_row or Point.are_same_col

    local surrounding_points_lower_end = ai_helpers.get_surrounding_points(lower_end)
    local surrounding_points_upper_end = ai_helpers.get_surrounding_points(upper_end)
    ---@type Point[]
    local surrounding_points =
        utils.concat(surrounding_points_lower_end, surrounding_points_upper_end)

    local potentital_points = utils.filter(surrounding_points, function(candidate_point)
        local is_candidate_not_a_hit_point =
            not utils.includes(self.hits, candidate_point, Point.are_equal)
        local is_candidate_not_a_miss_point =
            not utils.includes(self.misses, candidate_point, Point.are_equal)
        local is_candidate_in_correct_direction = direction_equality_fn(lower_end, candidate_point)
            and direction_equality_fn(upper_end, candidate_point)
        return is_candidate_in_correct_direction
            and is_candidate_not_a_hit_point
            and is_candidate_not_a_miss_point
    end)
    if #potentital_points == 0 then
        error("Something went wrong. Should have available points", 2)
    end

    return potentital_points[math.random(1, #potentital_points)]
end

---@return Point
function MediumAI:_seek_second_hit()
    ---@type Point
    local point = self.lower_end
    local surrounding_points = ai_helpers.get_surrounding_points(point)
    local potentital_points = utils.filter(surrounding_points, function(candidate_point)
        return not utils.includes(self.misses, candidate_point, Point.are_equal)
    end)
    if #potentital_points == 0 then
        error("Something went wrong. Should have available points", 2)
    end
    return potentital_points[math.random(1, #potentital_points)]
end

return MediumAI
