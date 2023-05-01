local Interface = require("battleship.ui")

local PromptInterface = {}
setmetatable(PromptInterface, { __index = Interface })

---@param buffer number
local read_buffer = function(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1]
end

---@param opts InterfaceOptions
function PromptInterface:new(opts)
    local instance = Interface:new(opts)
    setmetatable(instance, { __index = PromptInterface })
    vim.api.nvim_buf_set_keymap(instance.buf, "n", "<CR>", "<Nop>", { silent = true })
    return instance
end

---Reads the prompt until a CR is emitted
---@param on_submit function callback function to run after submission
function PromptInterface:read(on_submit)
    vim.cmd("startinsert")
    vim.keymap.set("i", "<CR>", function()
        local content = read_buffer(self.buf)
        vim.cmd("stopinsert")
        vim.api.nvim_buf_set_lines(self.buf, 0, 1, false, { "" })
        local row = content:sub(1, 1)
        local col = tonumber(content:sub(2, 2))
        vim.keymap.del("i", "<CR>", { buffer = self.buf })
        on_submit({ row = row, col = col })
    end, { buffer = self.buf, silent = true })
end

return PromptInterface
