local Board = require("battleship.boards")
local Interface = require("battleship.ui")

local constants = require("battleship.constants")
local utils = require("battleship.utils")

local rows = constants.BOARD_ROWS
local rows_indexes = constants.BOARD_ROWS_INDEXES
local ns = vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)

local divider_row = 11

---@class AssembleInterface: Interface
---@field board Board Current board being assembled
---@field mode "position" | "selection"
---@field error boolean Whether current assemble has an error
---@field current_ship_cells RowCol[] Coordinates of current ship being positioned
---@field is_horizontal boolean Whether current positioning is horizontal (false means vertical)
---@field hl_ids integer[][] Highlight ids of current_ship locations
---@field vdivider string Vertical Divider
local AssembleInterface = {
    board = {
        state = {},
        name = " Assemble ",
    },
    mode = "position",
    error = false,
    current_ship_cells = {},
    current_ship_name = "",
    is_horizontal = true,
    hl_ids = {},
}
setmetatable(AssembleInterface, { __index = Interface })

---Wraps actions that require to modify the buffer
---@param buf integer
---@param action fun(): unknown?
local wrap_action = function(buf, action)
    return function()
        ---@diagnostic disable-next-line:redundant-parameter
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
        action()
        -- TODO: do pcall here as the buffer might be erased by action
        ---@diagnostic disable-next-line:redundant-parameter
        pcall(vim.api.nvim_buf_set_option, buf, "modifiable", false)
    end
end

---@param args { hdivider: string?, vdivider: string?, on_complete: fun(assembled: AssembleInterface): nil }
---@return Interface
function AssembleInterface:new(args)
    -- Note: if we do this require outside of this function, configs comes empty
    local configs = require("battleship").configs

    local height = 1 + 10 + 1 + #configs.ships
    local width = 45
    local ui = vim.api.nvim_list_uis()[1]
    local screen_width = ui.width
    local screen_height = ui.height

    local row = math.floor((screen_height - height) / 2 - 4)
    local col = math.floor((screen_width - width) / 2)

    local instance = Interface:new({
        title = " Assemble ",
        width = width,
        height = height,
        col = col,
        row = row,
    })

    self.vdivider = configs.vdivider
    self.hdivider = configs.hdivider
    self.ships = utils.map(configs.ships, function(ship)
        return {
            chosen = false,
            name = ship.name,
            size = ship.size,
        }
    end)
    self.position_mode_cursor_pos = { 1, 1 }
    self.selection_mode_cursor_pos = { divider_row + 2, 0 }
    setmetatable(instance, { __index = AssembleInterface })
    self.board = Board:new({ empty = true, name = "Assemble" })
    self.on_complete = args.on_complete
    return instance
end

---Map a board coordinate to a ui coordinate
---@param row string
---@param col integer
---@return integer[] coordinates zero-indexed array with row and col, respectively
function AssembleInterface:_map_board_coordinate_to_ui(row, col)
    local space = 3 -- left pad + number + right pad
    local horizontal_offset = space + #self.vdivider
    local min_col = horizontal_offset + 1
    local row_index = rows_indexes[row]
    local col_index = min_col + (col - 1) * horizontal_offset
    return {
        row_index,
        col_index,
    }
end

---Sets char to given position
---@param row integer Row index (0-based index)
---@param col integer Col index (0-based index)
---@param char string Character to write
---@param highlight string? Highlight group
function AssembleInterface:set_char(row, col, char, highlight)
    vim.api.nvim_buf_set_text(self.buf, row, col, row, col + 1, { char })
    if highlight then
        self:set_highlight(row, col, highlight)
    end
end

---Set highlight for the assemble buffer
---@param row integer Row index (0-based index)
---@param col integer Col index (0-based index)
---@param highlight string Highlight group
function AssembleInterface:set_highlight(row, col, highlight)
    if not self.hl_ids[row] then
        self.hl_ids[row] = {}
    end
    local id = self.hl_ids[row][col]
    if id then
        vim.api.nvim_buf_set_extmark(
            self.buf,
            ns,
            row,
            col,
            { end_col = col + 1, hl_group = highlight, id = id }
        )
    else
        local new_id = vim.api.nvim_buf_set_extmark(
            self.buf,
            ns,
            row,
            col,
            { end_col = col + 1, hl_group = highlight }
        )
        self.hl_ids[row][col] = new_id
    end
end
---Reset highlight for the assemble buffer
---@param row integer Row index (0-based index)
---@param col integer Col index (0-based index)
function AssembleInterface:reset_highlight(row, col)
    if not self.hl_ids[row] or not self.hl_ids[row][col] then
        return
    end
    vim.api.nvim_buf_del_extmark(self.buf, ns, self.hl_ids[row][col])
end

---@param error boolean
---@param new_cell RowCol
function AssembleInterface:_handle_highlight(error, new_cell)
    local has_error_before = self.error
    self.error = error
    if has_error_before and not error then
        for _, cell in ipairs(self.current_ship_cells) do
            local line, col_start = unpack(self:_map_board_coordinate_to_ui(cell[1], cell[2]))
            self:set_highlight(line, col_start, "AssembleAvailable")
        end
    elseif not has_error_before and error then
        for _, cell in ipairs(self.current_ship_cells) do
            local line, col_start = unpack(self:_map_board_coordinate_to_ui(cell[1], cell[2]))
            self:set_highlight(line, col_start, "AssembleUnavailable")
        end
    else
        local line, col_start = unpack(self:_map_board_coordinate_to_ui(new_cell[1], new_cell[2]))
        self:set_highlight(line, col_start, error and "AssembleUnavailable" or "AssembleAvailable")
    end
end

---Function to handle "easy" movements such as:
---Vertical movement of vertical ships;
---Horizontal movement or horizontal ships.
---@param point_to_add RowCol row and col tuple
---@param position "head" | "tail" position to insert the new point
function AssembleInterface:_handle_swap_position(point_to_add, position)
    local index_to_add = position == "head" and 1 or #self.current_ship_cells + 1
    table.insert(self.current_ship_cells, index_to_add, point_to_add)
    local index_to_remove = position == "tail" and 1 or #self.current_ship_cells
    local popped_row, popped_col = unpack(table.remove(self.current_ship_cells, index_to_remove))
    local popped_row_ui, popped_col_ui =
        unpack(self:_map_board_coordinate_to_ui(popped_row, popped_col))
    local pushed_row_ui, pushed_col_ui =
        ---Currently, luals cannot infer type from unpack
        ---See: https://github.com/LuaLS/lua-language-server/issues/1353
        ---@diagnostic disable:param-type-mismatch
        unpack(self:_map_board_coordinate_to_ui(unpack(point_to_add)))
    -- TODO: perhaps we can do error and (and check only the new place) -> Try it
    local new_error = not utils.every(self.current_ship_cells, function(cell)
        return self.board.state[cell[1]][cell[2]] == "."
    end)
    self:set_char(popped_row_ui, popped_col_ui, self.board.state[popped_row][popped_col])
    self:set_char(pushed_row_ui, pushed_col_ui, tostring(#self.current_ship_cells))
    self:_handle_highlight(new_error, point_to_add)
end

---Function to handle "complex" movements such as:
---Vertical movement of horizontal ships;
---Horizontal movement of vertical ships;
---Rotation
---@param mapping_fn fun(element: RowCol): RowCol Mapping function to transform ship cells
function AssembleInterface:_handle_complex_movement(mapping_fn)
    local new_current_ship = utils.map(self.current_ship_cells, mapping_fn)
    local old_ship = self.current_ship_cells
    self.current_ship_cells = new_current_ship
    local new_error = not utils.every(self.current_ship_cells, function(cell)
        return self.board.state[cell[1]][cell[2]] == "."
    end)
    for index, coordinate in ipairs(self.current_ship_cells) do
        local popped_row, popped_col = unpack(old_ship[index])
        ---@cast popped_row string
        ---@cast popped_col integer
        local popped_row_ui, popped_col_ui =
            unpack(self:_map_board_coordinate_to_ui(popped_row, popped_col))
        local pushed_row, pushed_col = unpack(coordinate)
        local pushed_row_ui, pushed_col_ui =
            unpack(self:_map_board_coordinate_to_ui(pushed_row, pushed_col))
        self:set_char(popped_row_ui, popped_col_ui, self.board.state[popped_row][popped_col])
        self:set_char(pushed_row_ui, pushed_col_ui, tostring(#self.current_ship_cells))
        self:set_highlight(
            pushed_row_ui,
            pushed_col_ui,
            new_error and "AssembleUnavailable" or "AssembleAvailable"
        )
    end
    self.error = new_error
end

function AssembleInterface:_handle_left_movement()
    local reference_cell = self.current_ship_cells[1]
    local new_col = reference_cell[2] - 1
    if new_col < 1 then
        return
    end
    if self.is_horizontal then
        local new_row = reference_cell[1]
        self:_handle_swap_position({ new_row, new_col }, "head")
        return
    end
    self:_handle_complex_movement(function(ship_coords)
        local row, col = unpack(ship_coords)
        return { row, col - 1 }
    end)
end

function AssembleInterface:_handle_right_movement()
    local reference_cell = self.current_ship_cells[#self.current_ship_cells]
    local new_col = reference_cell[2] + 1
    if new_col > 10 then
        return
    end
    if self.is_horizontal then
        local new_row = reference_cell[1]
        self:_handle_swap_position({ new_row, new_col }, "tail")
        return
    end
    self:_handle_complex_movement(function(ship_coords)
        local row, col = unpack(ship_coords)
        return { row, col + 1 }
    end)
end

function AssembleInterface:_handle_up_movement()
    local reference_cell = self.current_ship_cells[1]
    local new_row_index = rows_indexes[reference_cell[1]] - 1
    if new_row_index < 1 then
        return
    end
    if self.is_horizontal then
        self:_handle_complex_movement(function(ship_coords)
            local _, col = unpack(ship_coords)
            local new_row = rows[new_row_index]
            return { new_row, col }
        end)
        return
    end
    local new_row = rows[new_row_index]
    local new_col = reference_cell[2]
    self:_handle_swap_position({ new_row, new_col }, "head")
end

function AssembleInterface:_handle_down_movement()
    local reference_cell = self.current_ship_cells[#self.current_ship_cells]
    local new_row_index = rows_indexes[reference_cell[1]] + 1
    if new_row_index > 10 then
        return
    end
    if self.is_horizontal then
        self:_handle_complex_movement(function(ship_coords)
            local row, col = unpack(ship_coords)
            local new_row = rows[rows_indexes[row] + 1]
            return { new_row, col }
        end)
        return
    end
    local new_row = rows[new_row_index]
    local new_col = reference_cell[2]
    self:_handle_swap_position({ new_row, new_col }, "tail")
end

function AssembleInterface:_handle_horizontal_to_vertical_rotation()
    local rotation_point_row, rotation_point_col = unpack(self.current_ship_cells[1])
    local shift =
        math.max(0, rows_indexes[rotation_point_row] + #self.current_ship_cells - divider_row)
    self:_handle_complex_movement(function(cell)
        local row, col = unpack(cell)
        local old_row_index = rows_indexes[row]
        local new_row = rows[old_row_index + col - rotation_point_col - shift]
        return { new_row, rotation_point_col }
    end)
end

function AssembleInterface:_handle_vertical_to_horizontal_rotation()
    local rotation_point_row, rotation_point_col = unpack(self.current_ship_cells[1])
    local rotation_point_row_index = rows_indexes[rotation_point_row]
    local shift = math.max(0, rotation_point_col + #self.current_ship_cells - divider_row)
    self:_handle_complex_movement(function(cell)
        local row = unpack(cell)
        local old_row_index = rows_indexes[row]
        local new_col = rotation_point_col + old_row_index - rotation_point_row_index - shift
        return { rotation_point_row, new_col }
    end)
end

function AssembleInterface:_handle_position_confirm()
    local ship_size = #self.current_ship_cells
    for _, cell in ipairs(self.current_ship_cells) do
        self.board.state[cell[1]][cell[2]] = tostring(ship_size)
        local row_ui, col_ui = unpack(self:_map_board_coordinate_to_ui(unpack(cell)))
        self:reset_highlight(row_ui, col_ui)
    end
    local ship_index = -1
    for index, ship in ipairs(self.ships) do
        if ship.name == self.current_ship_name then
            ship_index = index
            ship.chosen = true
            break
        end
    end
    local line_number = divider_row + ship_index
    local buf = self.buf
    vim.api.nvim_buf_set_lines(
        buf,
        line_number,
        line_number + 1,
        false,
        { string.format("%s (%d): ", self.current_ship_name, ship_size) }
    )
    local next_ship
    for _, ship in ipairs(self.ships) do
        if not ship.chosen then
            next_ship = ship
            break
        end
    end
    if next_ship then
        self:_put_ship_on_board(next_ship)
        return
    end
    self:destroy()
    self:on_complete()
end

---@param ship { name: string, size: integer }
function AssembleInterface:_put_ship_on_board(ship)
    local name = ship.name
    local size = ship.size
    local next_current_ship = {}
    for col = 1, size do
        table.insert(next_current_ship, { rows[1], col })
    end
    local new_error = not utils.every(next_current_ship, function(cell)
        return self.board.state[cell[1]][cell[2]] == "."
    end)
    for _, cell in ipairs(next_current_ship) do
        local row_index, col_index = unpack(self:_map_board_coordinate_to_ui(unpack(cell)))
        vim.api.nvim_buf_set_text(
            self.buf,
            row_index,
            col_index,
            row_index,
            col_index + 1,
            { tostring(size) }
        )
        self:set_highlight(
            row_index,
            col_index,
            new_error and "AssembleUnavailable" or "AssembleAvailable"
        )
    end
    self.is_horizontal = true
    self.current_ship_cells = next_current_ship
    self.current_ship_name = name
end

---@param new_ship { name: string, size: integer }
function AssembleInterface:_handle_change_current_ship(new_ship)
    local old_ship = self.current_ship_cells
    for _, cell in ipairs(old_ship) do
        local row, col = unpack(cell)
        local row_ui, col_ui = unpack(self:_map_board_coordinate_to_ui(row, col))
        self:reset_highlight(row_ui, col_ui)
        self:set_char(row_ui, col_ui, self.board.state[row][col])
    end
    self:_put_ship_on_board(new_ship)
end

---@param shift -1 | 1
function AssembleInterface:_handle_selection_movement(shift)
    local row, col = unpack(vim.api.nvim_win_get_cursor(self.win))
    local next_row = row + shift
    local number_of_ships = #self.ships
    local max_row = divider_row + number_of_ships + 1 -- (1-based index)
    local min_row = max_row - number_of_ships + 1 -- (1-based index)
    vim.api.nvim_win_set_cursor(self.win, { math.max(min_row, math.min(next_row, max_row)), col })
end

function AssembleInterface:show()
    Interface.show(self)
    local buf = self.buf
    local vdivider = self.vdivider
    local hdivider = self.hdivider
    local lines = { string.format("   %s", vdivider) }
    for index, row in ipairs(rows) do
        lines[1] = string.format("%s %d %s", lines[1], index - 1, vdivider)
        table.insert(lines, string.format(" %s %s", row, vdivider))
        for _, col in ipairs(self.board.state[row]) do
            lines[index + 1] = string.format("%s %s %s", lines[index + 1], col, vdivider)
        end
    end
    for _, ship in ipairs(self.ships) do
        table.insert(lines, string.format("%s (%d): ", ship.name, ship.size))
    end
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)
    local first_ship = self.ships[1]
    self:_put_ship_on_board(first_ship)

    local divider = string.rep(hdivider, vim.api.nvim_win_get_width(self.win))
    vim.api.nvim_buf_set_lines(buf, divider_row, divider_row, false, { divider })
    vim.api.nvim_win_set_cursor(self.win, self.position_mode_cursor_pos)
    ---@diagnostic disable-next-line:redundant-parameter
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    local opts = {
        buffer = buf,
        remap = true,
        silent = true,
    }
    vim.keymap.set(
        "n",
        "l",
        wrap_action(buf, function()
            if self.mode == "position" then
                self:_handle_right_movement()
            end
        end),
        opts
    )
    vim.keymap.set(
        "n",
        "h",
        wrap_action(buf, function()
            if self.mode == "position" then
                self:_handle_left_movement()
            end
        end),
        opts
    )
    vim.keymap.set(
        "n",
        "j",
        wrap_action(buf, function()
            if self.mode == "position" then
                self:_handle_down_movement()
                return
            end
            if self.mode == "selection" then
                self:_handle_selection_movement(1)
                return
            end
        end),
        opts
    )
    vim.keymap.set(
        "n",
        "k",
        wrap_action(buf, function()
            if self.mode == "position" then
                self:_handle_up_movement()
            end
            if self.mode == "selection" then
                self:_handle_selection_movement(-1)
                return
            end
        end),
        opts
    )
    vim.keymap.set(
        "n",
        "R",
        wrap_action(buf, function()
            if self.mode == "position" then
                if self.is_horizontal then
                    self:_handle_horizontal_to_vertical_rotation()
                else
                    self:_handle_vertical_to_horizontal_rotation()
                end
                self.is_horizontal = not self.is_horizontal
            end
        end),
        opts
    )
    vim.keymap.set(
        "n",
        "<CR>",
        wrap_action(buf, function()
            if self.mode == "position" then
                if self.error then
                    return
                end
                self:_handle_position_confirm()
                return
            end
            if self.mode == "selection" then
                local cursor_row_ui = unpack(vim.api.nvim_win_get_cursor(self.win))
                local ship_index = cursor_row_ui - divider_row - 1
                local new_ship = self.ships[ship_index]
                if new_ship.chosen then
                    return
                end
                self:_handle_change_current_ship(new_ship)
                self.mode = "position"
                vim.api.nvim_win_set_cursor(self.win, self.position_mode_cursor_pos)
            end
        end),
        opts
    )
    vim.keymap.set("n", "<Tab>", function()
        if self.mode == "position" then
            self.mode = "selection"
            vim.api.nvim_win_set_cursor(self.win, self.selection_mode_cursor_pos)
        else
            self.mode = "position"
            vim.api.nvim_win_set_cursor(self.win, self.position_mode_cursor_pos)
        end
    end, opts)
end

return AssembleInterface
