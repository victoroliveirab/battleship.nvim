local constants = require("battleship.constants")

local Point = {}

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

---Creates a point
---@param coordinates Coordinates
---@return Point
Point.create = function(coordinates)
    local row = string.upper(coordinates.row)
    local col = coordinates.col
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
        and point.row_index <= 9
        and point.col_index >= 1
        and point.col_index <= 9
end

return Point
