local constants = require("battleship.constants")

local Point = {}

---Get row index
---@param row string
---@return integer row Row's index or -1 if not found
local get_row_index = function(row)
    for index, value in ipairs(constants.BOARD_ROWS) do
        if value == row then
            return index
        end
    end
    return -1
end

---Creates a point
---@param coordinates Coordinates
---@return Point
Point.create = function(coordinates)
    local row = coordinates.row and string.upper(coordinates.row) or "X"
    local col = coordinates.col or -1
    return {
        row = row,
        col = col,
        row_index = get_row_index(row),
        col_index = col + 1,
    }
end

---Checks if a point is valid
---@param point Point
---@return boolean
Point.is_valid = function(point)
    return point.row_index >= 1
        and point.row_index <= 10
        and point.col_index >= 1
        and point.col_index <= 10
end

---Checks if two points are in the same row
---@param point_a Point
---@param point_b Point
---@return boolean
Point.are_same_row = function(point_a, point_b)
    return point_a.row == point_b.row and point_a.row_index == point_b.row_index
end

---Checks if two points are in the same col
---@param point_a Point
---@param point_b Point
---@return boolean
Point.are_same_col = function(point_a, point_b)
    return point_a.col == point_b.col and point_a.col_index == point_b.col_index
end

---Checks if two points are the same
---@param point_a Point
---@param point_b Point
---@return boolean
Point.are_equal = function(point_a, point_b)
    return Point.are_same_row(point_a, point_b) and Point.are_same_col(point_a, point_b)
end

return Point
