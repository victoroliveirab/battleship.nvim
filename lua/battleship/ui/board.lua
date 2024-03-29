local Interface = require("battleship.ui")
local Point = require("battleship.boards.point")

local constants = require("battleship.constants")

local rows = constants.BOARD_ROWS
local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)
local PIPE = constants.CHARS_MAP.PIPE

---@class BoardInterface: Interface
---@field boards { attack: AttackBoard, defense: AttackBoard, player: DefenseBoard }
local BoardInterface = {
    min_width = 45,
    min_height = 20,
    current_board = "player",
    boards = {},
}
setmetatable(BoardInterface, { __index = Interface })

local padding = 3

---Get buffer coordinates by board's row and col
---@param point Point
---@return { row: integer, col: integer }
local get_buffer_coordinates = function(point)
    local row_index = point.row_index + 1
    local col_index = (padding + #PIPE) * point.col_index + 1
    return { row = row_index, col = col_index }
end

---Creates a new Board Interface
---@param opts InterfaceOptions
---@return Interface
function BoardInterface:new(opts)
    local options = vim.tbl_extend("force", opts, {
        focusable = false,
    })
    local instance = Interface:new(options)
    setmetatable(instance, { __index = BoardInterface })
    return instance
end

---Attaches boards to interface
---@param params { attack: AttackBoard, defense: AttackBoard, player: DefenseBoard }
---@return nil
function BoardInterface:attach_boards(params)
    self.boards.attack = params.attack
    self.boards.defense = params.defense
    self.boards.player = params.player
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

function BoardInterface:_format_board_cell(row, col_index, value)
    local is_player_attack = self.current_board == "player"
    if is_player_attack or value == "~" then
        return value
    end

    local player_board_cell = self.boards.player.state[row][col_index]
    if player_board_cell ~= "." then
        return player_board_cell
    end
    return value
end

---Renders the current board to the buffer
---@return nil
function BoardInterface:render()
    local hit_hl = self.current_board == "player" and "PlayerBoardHit" or "CPUBoardHit"
    local miss_hl = self.current_board == "player" and "PlayerBoardMiss" or "CPUBoardMiss"
    local board = self.current_board == "player" and self.boards.attack or self.boards.defense
    local board_lines = { string.format("   %s", PIPE) }
    local highlights = {}
    for index, row in ipairs(rows) do
        board_lines[1] = string.format("%s %d %s", board_lines[1], index - 1, PIPE)
        table.insert(board_lines, string.format(" %s %s", row, PIPE))
        for col_index, value in ipairs(board.state[row]) do
            local formatted_value = self:_format_board_cell(row, col_index, value)
            board_lines[index + 1] =
                string.format("%s %s %s", board_lines[index + 1], formatted_value, PIPE)
            if value ~= "." then
                local point = Point.create({ row = row, col = col_index - 1 })
                local indexes = get_buffer_coordinates(point)
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

---Set board to show
---@param board "player"|"cpu"
function BoardInterface:set_board(board)
    self.current_board = board
    self:update_title(
        self.current_board == "player" and self.boards.attack.name or self.boards.defense.name
    )
end

function BoardInterface:toggle()
    self:set_board(self.current_board == "cpu" and "player" or "cpu")
end

---Updates specific part of the buffer
---@param point Point
---@param value string
---@return nil
function BoardInterface:update_board(point, value)
    local indexes = get_buffer_coordinates(point)
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
    vim.api.nvim_win_set_config(
        self.win,
        { title = string.format(" %s ", title), title_pos = "center" }
    )
    -- For some reason, after the above call we have to reset the hl group
    -- Perhaps some default option is assumed on set_config?
    self:_set_hl_group()
end

return BoardInterface
