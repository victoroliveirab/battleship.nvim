local Interface = require("battleship.ui")

local constants = require("battleship.constants")

---@class BoardInterface: Interface
local BoardInterface = {
    min_width = 45,
    -- TODO: alternate between 11 and 20 to extended and condensed versions
    min_height = 20,
}
setmetatable(BoardInterface, { __index = Interface })

local padding = 3
local padding_str = string.rep(" ", padding)

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

---Creates a new Board Interface
---@param opts InterfaceOptions
---@return Interface
function BoardInterface:new(opts)
    local options = vim.tbl_extend("force", opts, {
        focusable = false,
        title = " Attack Board ",
        title_pos = "center",
    })
    local instance = Interface:new(options)
    setmetatable(instance, { __index = BoardInterface })
    return instance
end

---Wipe buffer and write to it
---@param lines string[]
---@return nil
function BoardInterface:write(lines)
    vim.api.nvim_buf_set_lines(self.buf, 1, 1 + #lines, false, lines)
end

---Prints a board to the buffer
---@param board Board
---@param rows string[]
---@return nil
function BoardInterface:print_board(board, rows)
    -- local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)
    -- vim.api.nvim_buf_set_lines(self.buf, 0, 1, false, { "HEADER" })
    -- vim.api.nvim_buf_add_highlight(self.buf, ns, "BoardMiss", 0, 1, -1)
    local board_lines = { padding_str .. "| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |" }
    for index, row in ipairs(rows) do
        table.insert(board_lines, " " .. row .. " | ")
        for _, value in ipairs(board.state[row]) do
            board_lines[index + 1] = board_lines[index + 1] .. value .. " | "
        end
    end
    table.insert(board_lines, string.rep("-", vim.api.nvim_win_get_width(self.win)))
    self:write(board_lines)
end

---Updates specific part of the buffer
---@param row string
---@param col number
---@param value string
---@return nil
function BoardInterface:update_board(row, col, value)
    local row_index = get_row_index(row) + 1
    local col_index = (padding + 1) * col + 1
    vim.api.nvim_buf_set_text(self.buf, row_index, col_index, row_index, col_index + 1, { value })
    local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)
    vim.api.nvim_buf_add_highlight(
        self.buf,
        ns,
        value == "~" and "BoardMiss" or "BoardHit",
        row_index,
        col_index,
        col_index + 1
    )
end

---Updates title of the window
---@param title string
---@return nil
function BoardInterface:update_title(title)
    vim.api.nvim_win_set_config(self.win, { title = title })
end

return BoardInterface
