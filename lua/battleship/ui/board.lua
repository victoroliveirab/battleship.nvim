local Interface = require("battleship.ui")

local constants = require("battleship.constants")

local rows = constants.BOARD_ROWS
local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)

---@class BoardInterface: Interface
---@field board { attack: AttackBoard, defense: AttackBoard }
local BoardInterface = {
    min_width = 45,
    min_height = 20,
    current_board = "player",
    boards = {
        attack = {},
        defense = {},
    },
}
setmetatable(BoardInterface, { __index = Interface })

local padding = 3

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

---Get buffer coordinates by board's row and col
---@param row string
---@param col integer
---@return { row: integer, col: integer }
local get_buffer_coordinates = function(row, col)
    local row_index = get_row_index(row) + 1
    local col_index = (padding + #constants.CHARS_MAP.PIPE) * col + 1
    return { row = row_index, col = col_index }
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

---Attaches boards to interface
---@param params { attack: AttackBoard, defense: AttackBoard }
---@return nil
function BoardInterface:attach_boards(params)
    self.boards.attack = params.attack
    self.boards.defense = params.defense
end

---Wipe buffer and write to it
---@param lines string[]
---@return nil
function BoardInterface:write(lines)
    vim.api.nvim_buf_set_lines(self.buf, 0, #lines, false, lines)
end

---Highlights areas of the buffer
---@param coordinates {row: integer, col: integer, group: string}[]
---@return nil
function BoardInterface:highlight(coordinates)
    for _, highlight in pairs(coordinates) do
        vim.api.nvim_buf_add_highlight(
            self.buf,
            ns,
            highlight.group,
            highlight.row,
            highlight.col,
            highlight.col + 1
        )
    end
end

---Renders the current board to the buffer
---@return nil
function BoardInterface:render()
    local hit_hl = self.current_board == "player" and "PlayerBoardHit" or "CPUBoardHit"
    local miss_hl = self.current_board == "player" and "PlayerBoardMiss" or "CPUBoardMiss"
    local board = self.current_board == "player" and self.boards.attack or self.boards.defense
    local board_lines = { string.format("   %s", constants.CHARS_MAP.PIPE) }
    local highlights = {}
    for index, row in ipairs(rows) do
        board_lines[1] =
            string.format("%s %d %s", board_lines[1], index - 1, constants.CHARS_MAP.PIPE)
        table.insert(board_lines, string.format(" %s %s", row, constants.CHARS_MAP.PIPE))
        for col_index, value in ipairs(board.state[row]) do
            board_lines[index + 1] =
                string.format("%s %s %s", board_lines[index + 1], value, constants.CHARS_MAP.PIPE)
            if value ~= "." then
                local indexes = get_buffer_coordinates(row, col_index)
                table.insert(
                    highlights,
                    vim.tbl_extend("error", indexes, { group = value == "~" and miss_hl or hit_hl })
                )
            end
        end
    end
    table.insert(
        board_lines,
        string.rep(constants.CHARS_MAP.DASH, vim.api.nvim_win_get_width(self.win))
    )

    table.insert(board_lines, 1, "")
    table.insert(board_lines, #board_lines, "")

    self:write(board_lines)
    self:highlight(highlights)
end

function BoardInterface:toggle()
    self.current_board = self.current_board == "player" and "cpu" or "player"
end

---Updates specific part of the buffer
---@param row string
---@param col number
---@param value string
---@return nil
function BoardInterface:update_board(row, col, value)
    local indexes = get_buffer_coordinates(row, col)
    local row_index = indexes.row
    local col_index = indexes.col
    vim.api.nvim_buf_set_text(self.buf, row_index, col_index, row_index, col_index + 1, { value })
    vim.api.nvim_buf_add_highlight(
        self.buf,
        ns,
        value == "~" and "PlayerBoardMiss" or "PlayerBoardHit",
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
