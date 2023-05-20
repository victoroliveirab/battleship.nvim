local ai_helpers = require("battleship.ais.helpers")
local utils = require("battleship.utils")

local test_helpers = require("battleship.tests.helpers")

---@param row string
---@param col integer
---@return Coordinates
local make_coordinates = function(row, col)
    return {
        row = row,
        col = col,
    }
end

local assert_get_surrounding_points = function()
    local points = utils.map({
        make_coordinates("A", 0),
        make_coordinates("A", 4),
        make_coordinates("A", 9),
        make_coordinates("E", 0),
        make_coordinates("E", 4),
        make_coordinates("E", 9),
        make_coordinates("J", 0),
        make_coordinates("J", 4),
        make_coordinates("J", 9),
    }, ai_helpers.get_surrounding_points)
    local expected = {
        { make_coordinates("A", 1), make_coordinates("B", 0) },
        { make_coordinates("A", 3), make_coordinates("A", 5), make_coordinates("B", 4) },
        { make_coordinates("A", 8), make_coordinates("B", 9) },
        { make_coordinates("D", 0), make_coordinates("E", 1), make_coordinates("F", 0) },
        {
            make_coordinates("D", 4),
            make_coordinates("E", 3),
            make_coordinates("E", 5),
            make_coordinates("F", 4),
        },
        { make_coordinates("D", 9), make_coordinates("E", 8), make_coordinates("F", 9) },
        { make_coordinates("I", 0), make_coordinates("J", 1) },
        { make_coordinates("I", 4), make_coordinates("J", 3), make_coordinates("J", 5) },
        { make_coordinates("I", 9), make_coordinates("J", 8) },
    }
    test_helpers.assert_equals_array_elements(expected, points)
end

assert_get_surrounding_points()
