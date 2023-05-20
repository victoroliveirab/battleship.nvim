local Point = require("battleship.boards.point")

local ai_helpers = require("battleship.ais.helpers")
local utils = require("battleship.utils")

local test_helpers = require("battleship.tests.helpers")

local assert_get_surrounding_points = function()
    local points = utils.map({
        Point.create({ row = "A", col = 0 }),
        Point.create({ row = "A", col = 4 }),
        Point.create({ row = "A", col = 9 }),
        Point.create({ row = "E", col = 0 }),
        Point.create({ row = "E", col = 4 }),
        Point.create({ row = "E", col = 9 }),
        Point.create({ row = "J", col = 0 }),
        Point.create({ row = "J", col = 4 }),
        Point.create({ row = "J", col = 9 }),
    }, ai_helpers.get_surrounding_points)
    local expected = {
        { Point.create({ row = "A", col = 1 }), Point.create({ row = "B", col = 0 }) },
        {
            Point.create({ row = "A", col = 3 }),
            Point.create({ row = "A", col = 5 }),
            Point.create({ row = "B", col = 4 }),
        },
        { Point.create({ row = "A", col = 8 }), Point.create({ row = "B", col = 9 }) },
        {
            Point.create({ row = "D", col = 0 }),
            Point.create({ row = "E", col = 1 }),
            Point.create({ row = "F", col = 0 }),
        },
        {
            Point.create({ row = "D", col = 4 }),
            Point.create({ row = "E", col = 3 }),
            Point.create({ row = "E", col = 5 }),
            Point.create({ row = "F", col = 4 }),
        },
        {
            Point.create({ row = "D", col = 9 }),
            Point.create({ row = "E", col = 8 }),
            Point.create({ row = "F", col = 9 }),
        },
        { Point.create({ row = "I", col = 0 }), Point.create({ row = "J", col = 1 }) },
        {
            Point.create({ row = "I", col = 4 }),
            Point.create({ row = "J", col = 3 }),
            Point.create({ row = "J", col = 5 }),
        },
        { Point.create({ row = "I", col = 9 }), Point.create({ row = "J", col = 8 }) },
    }
    test_helpers.assert_equals_array_elements(expected, points)
end

assert_get_surrounding_points()
