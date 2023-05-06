---@class Interface
---@field buf number
---@field win number
---@field opts InterfaceOptions
local Interface = {}
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
end

return Interface
