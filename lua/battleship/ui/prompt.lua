local Interface = require("battleship.ui")

---@class PromptInterface: Interface
local PromptInterface = {
    min_width = 2,
    min_height = 1,
}
setmetatable(PromptInterface, { __index = Interface })

---Reads the whole line
---@param buffer number Buffer handler
---@return string line Line's content
local read_buffer = function(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1]
end

---Parses the input
---@param input string Player's input
---@return Coordinates
local parse_input = function(input)
    local row = input:sub(1, 1)
    local col = tonumber(input:sub(2, 2))
    if not col or #input ~= 2 then
        error("Wrong format")
    end
    return { row = row, col = col }
end

---Creates a new prompt interface
---@param opts InterfaceOptions
---@return Interface
function PromptInterface:new(opts)
    local instance = Interface:new(opts)
    setmetatable(instance, { __index = PromptInterface })
    vim.api.nvim_buf_set_keymap(instance.buf, "n", "<CR>", "<Nop>", { silent = true })
    return instance
end

---Reads the prompt until a CR is emitted
---@param on_submit function callback function to run after submission
---@return nil
function PromptInterface:read(on_submit)
    vim.api.nvim_feedkeys("i", "n", true)
    vim.keymap.set("i", "<CR>", function()
        local content = read_buffer(self.buf)
        vim.api.nvim_buf_set_lines(self.buf, 0, 1, false, { "" })
        local ok, coordinates = pcall(parse_input, content)
        if ok then
            vim.cmd("stopinsert")
            vim.keymap.del("i", "<CR>", { buffer = self.buf })
            on_submit(coordinates)
        end
    end, { buffer = self.buf, silent = true })
end

return PromptInterface
