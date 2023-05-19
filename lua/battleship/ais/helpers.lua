local constants = require("battleship.constants")
local utils = require("battleship.utils")

local ROWS = constants.BOARD_ROWS

-- TODO: transfer this functions to a more generic board helpers file

---Get row index
---@param row string
---@return integer? row Row's index
local get_row_index = function(row)
    for index, value in ipairs(constants.BOARD_ROWS) do
        if value == row then
            return index
        end
    end
end

---Checks if a point is valid
---@param coordinate Coordinates
---@return boolean? is_valid Whether coordinate is valid
local is_valid_point = function(coordinate)
    return get_row_index(coordinate.row) and coordinate.col > 0 and coordinate.col <= 10
end

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
---@param point Coordinates
---@return Coordinates[] points The at most 4 points that surround the given point
local get_surrounding_points = function(point)
    local row_index = get_row_index(point.row)
    local col_index = point.col

    local left_point = { row = ROWS[row_index], col = col_index - 1 }
    local right_point = { row = ROWS[row_index], col = col_index + 1 }
    local up_point = { row = ROWS[row_index - 1], col = col_index }
    local down_point = { row = ROWS[row_index + 1], col = col_index }

    return utils.filter({ left_point, right_point, up_point, down_point }, is_valid_point)
end

return {
    get_random_point = get_random_point,
    get_surrounding_points = get_surrounding_points,
}
