local constants = require("battleship.constants")

---@class Interface
---@field buf number
---@field win number
---@field opts InterfaceOptions
---@field min_height number
---@field min_width number
local Interface = {
    min_width = 1,
    min_height = 1,
}
local Interface_mt = { __index = Interface }

---@class InterfaceOptions
---@field height number
---@field width number
---@field relative string
---@field border string
---@field row number
---@field col number
---@field style string
local default_opts = {
    height = 1,
    width = 1,
    relative = "editor",
    border = "double",
    row = 1,
    col = 1,
    style = "minimal",
}
---Creates a new interface
---@param opts InterfaceOptions
---@return Interface
function Interface:new(opts)
    opts = vim.tbl_extend("keep", opts, default_opts)
    local instance = {
        opts = opts,
        buf = vim.api.nvim_create_buf(false, true),
    }
    setmetatable(instance, Interface_mt)
    return instance
end

-- Borders: [ "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" ].

---Shows interface to the user
---@return nil
function Interface:show()
    if self.win then
        vim.api.nvim_win_close(self.win, true)
    end
    self.win = vim.api.nvim_open_win(self.buf, true, self.opts)
    self:_set_hl_group()
end

function Interface:_set_hl_group()
    vim.api.nvim_win_set_hl_ns(
        self.win,
        vim.api.nvim_create_namespace(constants.BATTLESHIP_NAMESPACE)
    )
end

---Resizes the interface
---@param params { col: number, row: number }
---@return nil
function Interface:resize(params)
    vim.api.nvim_win_set_config(
        self.win,
        { col = params.col, row = params.row, relative = "editor" }
    )
end

function Interface:clear()
    vim.api.nvim_buf_set_lines(self.buf, 0, vim.api.nvim_buf_line_count(self.buf), true, { "" })
end

return Interface
