local Game = require("battleship.loop")
local Stats = require("battleship.stats")

local available_args = {
    "easy",
    "easy_quick",
    "medium",
    "medium_quick",
}

---@param difficulty string?
local parse_difficulty = function(difficulty)
    if not difficulty or difficulty == "medium" then
        return "medium"
    end
    if difficulty == "easy" then
        return "easy"
    end
    return "medium"
end

vim.api.nvim_create_user_command("Battleship", function(command)
    if not vim.g.battleship_setup then
        require("battleship").setup({ run_tests = true })
    end
    Stats.init()
    local difficulty, mode = unpack(vim.split(command.args, "_"))
    -- Ready for assemble board code
    if not mode or mode ~= "quick" then
        difficulty = parse_difficulty(difficulty)
        local game = Game:new({
            difficulty = difficulty,
        })
        game:start()
        return
    end
    local game = Game:new({
        difficulty = difficulty,
    })
    game:start()
end, {
    desc = "Start a new game of Battleship with default settings",
    nargs = "?",
    complete = function(arg)
        return vim.tbl_filter(function(val)
            return vim.startswith(val, arg)
        end, available_args)
    end,
})
