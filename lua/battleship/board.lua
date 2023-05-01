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

local sample_board = {
    A = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    B = { ".", ".", ".", "5", "5", "5", "5", "5", ".", "." },
    C = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
    D = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
    E = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
    F = { ".", "4", ".", ".", ".", ".", ".", ".", ".", "." },
    G = { ".", "4", ".", ".", ".", "2", ".", ".", ".", "." },
    H = { ".", ".", ".", ".", ".", "2", ".", ".", ".", "." },
    I = { ".", ".", ".", ".", "3", "3", "3", ".", ".", "." },
    J = { ".", ".", ".", ".", ".", ".", ".", ".", ".", "." },
}

---@class Board
---@field state BoardState
---@field name string
---@field hits number[]
local Board = {}
Board.__index = Board

---Creates a new board
---@param name string Board's name
---@param empty boolean? Whether should be created an empty board
function Board:new(name, empty)
    local state = empty and vim.tbl_extend("keep", initial_board, {})
        or vim.tbl_extend("keep", sample_board, {})
    return setmetatable({ state = state, name = name, hits = { nil, 0, 0, 0, 0 } }, self)
end

return Board
