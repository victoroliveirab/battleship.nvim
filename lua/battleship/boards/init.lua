local Point = require("battleship.boards.point")

local ROWS = require("battleship.constants").BOARD_ROWS
local utils = require("battleship.utils")

--- @class BoardState
local initial_board = {
    A = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    B = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    C = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    D = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    E = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    F = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    G = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    H = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    I = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    J = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
}

---@param current_board BoardState
---@param point Point
---@return boolean
local available_spot = function(current_board, point)
    return Point.is_valid(point) and current_board[point.row][point.col] == "."
end

---Generate a random board
---@param empty boolean? whether should generate the board empty
---@return BoardState
local generate_board = function(empty)
    local board = utils.deepcopy(initial_board)
    if empty then
        return board
    end
    local ships_lenghts = { 5, 4, 3, 2 }
    local number_of_boats = #ships_lenghts
    for i = 1, number_of_boats do
        local ship_length = ships_lenghts[i]
        local positioned = false
        while not positioned do
            local is_horizontal = math.random(1, 2) == 1
            local points = {
                Point.create({ row = ROWS[math.random(1, 10)], col = math.random(1, 10) }),
            }
            for j = 2, ship_length do
                local row = is_horizontal and points[j - 1].row or ROWS[points[j - 1].row_index + 1]
                local col = is_horizontal and points[j - 1].col + 1 or points[j - 1].col
                table.insert(points, Point.create({ row = row, col = col }))
            end
            if
                utils.every(points, function(point)
                    return available_spot(board, point)
                end)
            then
                for _, point in ipairs(points) do
                    board[point.row][point.col] = tostring(ship_length)
                end
                positioned = true
            end
        end
    end
    return board
end

---@class Board
---@field state BoardState
---@field name string
local Board = {}
Board.__index = Board

---@class BoardOptions
---@field initial_state BoardState?
---@field empty boolean? Whether should be created an empty board
---@field name string Board's name

---Creates a new board
---@param options BoardOptions?
---@return Board
function Board:new(options)
    options = options or {}
    local name = options.name or "Board"
    local state = options.initial_state
        or utils.deepcopy(options.empty and initial_board or generate_board())
    return setmetatable({ state = state, name = name }, self)
end

return Board
