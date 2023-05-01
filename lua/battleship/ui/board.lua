local Interface = require("battleship.ui")

local constants = require("battleship.constants")

local BoardInterface = {}
setmetatable(BoardInterface, { __index = Interface })

local padding = 3
local padding_str = string.rep(" ", padding)

local get_row_index = function(row)
    for index, value in ipairs(constants.BOARD_ROWS) do
        if value == row then
            return index
        end
    end
end

---@param opts InterfaceOptions
function BoardInterface:new(opts)
    local options = vim.tbl_extend(
        "force",
        opts,
        { focusable = false, title = " Attack Board ", title_pos = "center" }
    )
    local instance = Interface:new(options)
    setmetatable(instance, { __index = BoardInterface })
    return instance
end

---Wipe buffer and write to it
---@param lines string[]
function BoardInterface:write(lines)
    vim.api.nvim_buf_set_lines(self.buf, 1, 1 + #lines, false, lines)
end

---Prints a board to the buffer
---@param board Board
---@param rows string[]
function BoardInterface:print_board(board, rows)
    local board_lines = { padding_str .. "| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |" }
    for index, row in ipairs(rows) do
        table.insert(board_lines, " " .. row .. " | ")
        for _, value in ipairs(board.state[row]) do
            board_lines[index + 1] = board_lines[index + 1] .. value .. " | "
        end
    end
    self:write(board_lines)
end

---Updates specific part of the buffer
---@param row number
---@param col number
---@param value string
function BoardInterface:update_board(row, col, value)
    local row_index = get_row_index(row) + 1
    local col_index = (padding + 1) * col + 1
    vim.api.nvim_buf_set_text(self.buf, row_index, col_index, row_index, col_index + 1, { value })
end

---Updates title of the window
---@param title string
function BoardInterface:update_title(title)
    vim.api.nvim_win_set_config(self.win, { title = title })
end

return BoardInterface
