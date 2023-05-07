local Interface = require("battleship.ui")

---@class LogInterface: Interface
local LogInterface = {
    min_width = 30,
    min_height = 1,
}
setmetatable(LogInterface, { __index = Interface })

---Creates a new Log Interface
---@param opts InterfaceOptions
---@return Interface
function LogInterface:new(opts)
    local options = vim.tbl_extend("force", opts, {
        focusable = false,
        title = " Log ",
        title_pos = "center",
    })
    local instance = Interface:new(options)
    setmetatable(instance, { __index = LogInterface })
    return instance
end

---Adds a line to the top of the buffer
---@param line string
function LogInterface:print(line)
    local str = "[" .. os.date("%H:%M:%S") .. "] " .. line
    vim.api.nvim_buf_set_lines(self.buf, 0, 0, true, { str })
end

return LogInterface
