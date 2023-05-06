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

---Generate a random board
---@return BoardState
local generate_board = function()
    return {
        A = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- B = { ".", ".", ".", "5", "5", "5", "5", "5", ".", "." },
        B = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        C = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- D = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
        D = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- E = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
        E = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- F = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
        F = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- G = { ".", "4", ".", ".", ".", "2", ".", ".", ".", "." },
        G = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        -- H = { ".", ".", ".", ".", ".", "2", ".", ".", ".", "." },
        H = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
        I = { ".", ".", ".", ".", "3", "3", "3", ".", ".", "." },
        J = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    }
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
function Board:new(options)
    options = options or {}
    local name = options.name or "Board"
    local state = options.initial_state
        or utils.deepcopy(options.empty and initial_board or generate_board())
    return setmetatable({ state = state, name = name }, self)
end

return Board
