local Point = require("battleship.boards.point")
local MediumAI = require("battleship.ais.medium")
local AttackBoard = require("battleship.boards.attack")
local DefenseBoard = require("battleship.boards.defense")

local test_helpers = require("battleship.tests.helpers")

local create_instances = function()
    local defense_board = DefenseBoard:new({
        initial_state = {
            A = { "4", ".", ".", ".", ".", ".", ".", ".", ".", "." },
            B = { "4", ".", ".", "5", "5", "5", "5", "5", ".", "." },
            C = { "4", ".", ".", ".", ".", ".", ".", ".", ".", "." },
            D = { "4", ".", ".", ".", ".", ".", ".", ".", ".", "." },
            E = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
            F = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
            G = { ".", ".", ".", ".", ".", "2", ".", ".", ".", "." },
            H = { ".", ".", ".", ".", ".", "2", ".", ".", ".", "." },
            I = { ".", ".", ".", ".", "3", "3", "3", ".", ".", "." },
            J = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        },
    })
    local attack_board = AttackBoard:new()

    attack_board:set_opposite(defense_board)

    local ai = MediumAI:new({ board = attack_board })

    return { ai = ai, attack_board = attack_board, defense_board = defense_board }
end

local assert_first_hit = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point = Point.create({ row = "B", col = 3 })

    ai:mark_hit(hit_point)

    test_helpers.assert_equals_array_elements(ai.hits, { hit_point })
    test_helpers.assert_equals(ai.lower_end, hit_point)
    test_helpers.assert_equals(ai.upper_end, nil)
    test_helpers.assert_equals(ai.direction, nil)
end

local assert_second_hit_to_the_right = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "B", col = 3 })
    local hit_point_2 = Point.create({ row = "B", col = 4 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    test_helpers.assert_equals_array_elements(ai.hits, { hit_point_1, hit_point_2 })
    test_helpers.assert_equals(ai.lower_end, hit_point_1)
    test_helpers.assert_equals(ai.upper_end, hit_point_2)
    test_helpers.assert_equals(ai.direction, "x")
end

local assert_second_hit_to_the_left = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "B", col = 4 })
    local hit_point_2 = Point.create({ row = "B", col = 3 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    test_helpers.assert_equals_array_elements(ai.hits, { hit_point_1, hit_point_2 })
    test_helpers.assert_equals(ai.lower_end, hit_point_2)
    test_helpers.assert_equals(ai.upper_end, hit_point_1)
    test_helpers.assert_equals(ai.direction, "x")
end

local assert_second_hit_above = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "B", col = 0 })
    local hit_point_2 = Point.create({ row = "A", col = 0 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    test_helpers.assert_equals_array_elements(ai.hits, { hit_point_1, hit_point_2 })
    test_helpers.assert_equals(ai.lower_end, hit_point_2)
    test_helpers.assert_equals(ai.upper_end, hit_point_1)

    test_helpers.assert_equals(ai.direction, "y")
end

local assert_second_hit_below = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "A", col = 0 })
    local hit_point_2 = Point.create({ row = "B", col = 0 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    test_helpers.assert_equals_array_elements(ai.hits, { hit_point_1, hit_point_2 })
    test_helpers.assert_equals(ai.lower_end, hit_point_1)
    test_helpers.assert_equals(ai.upper_end, hit_point_2)
    test_helpers.assert_equals(ai.direction, "y")
end

local assert_third_hit_correct_direction_corner = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "A", col = 0 })
    local hit_point_2 = Point.create({ row = "B", col = 0 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    local iteration = 0
    repeat
        iteration = iteration + 1
        local next_point = Point.create(ai:next_move())
        test_helpers.assert_equals("C", next_point.row)
        test_helpers.assert_equals(0, next_point.col)
    until iteration == 20
end

local assert_third_hit_correct_direction_border = function()
    local instances = create_instances()
    local ai = instances.ai

    local hit_point_1 = Point.create({ row = "B", col = 0 })
    local hit_point_2 = Point.create({ row = "C", col = 0 })

    ai:mark_hit(hit_point_1)
    ai:mark_hit(hit_point_2)

    local possibilities = {
        Point.create({ row = "A", col = 0 }),
        Point.create({ row = "D", col = 0 }),
    }

    local next_point = Point.create(ai:next_move())

    ai:mark_hit(next_point)
    test_helpers.assert_belongs(possibilities, next_point, Point.are_equal)

    if Point.are_equal(next_point, possibilities[1]) then
        test_helpers.assert_equals(ai.lower_end.row, next_point.row)
        test_helpers.assert_equals(ai.lower_end.col, next_point.col)
    else
        test_helpers.assert_equals(ai.upper_end.row, next_point.row)
        test_helpers.assert_equals(ai.upper_end.col, next_point.col)
    end
end

assert_first_hit()
assert_second_hit_to_the_right()
assert_second_hit_to_the_left()
assert_second_hit_above()
assert_second_hit_below()
assert_third_hit_correct_direction_corner()
test_helpers.run_multiple(assert_third_hit_correct_direction_border, 20)
