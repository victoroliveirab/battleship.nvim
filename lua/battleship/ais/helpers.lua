local Point = require("battleship.boards.point")

local constants = require("battleship.constants")
local utils = require("battleship.utils")

local ROWS = constants.BOARD_ROWS

-- TODO: transfer this functions to a more generic board helpers file

---Gets a random point on the board
---@return Coordinates
local get_random_point = function()
    local row = ROWS[math.random(1, 10)]
    local col = math.random(1, 10)
    return {
        row = row,
        col = col,
    }
end

---Gets the points surrouding a point in the board.
---@param point Point
---@return Point[] points The at most 4 points that surround the given point
local get_surrounding_points = function(point)
    local row_index = point.row_index
    local col = point.col

    local left_point = Point.create({ row = ROWS[row_index], col = col - 1 })
    local right_point = Point.create({ row = ROWS[row_index], col = col + 1 })
    local up_point = Point.create({ row = ROWS[row_index - 1], col = col })
    local down_point = Point.create({ row = ROWS[row_index + 1], col = col })

    return utils.filter({ left_point, right_point, up_point, down_point }, Point.is_valid)
end

return {
    get_random_point = get_random_point,
    get_surrounding_points = get_surrounding_points,
}
