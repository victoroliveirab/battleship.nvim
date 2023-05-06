---@class UiDefaultOpts
---@field height number
---@field width number
---@field row number
---@field col number

return {
    BATTLESHIP_AUTO_GROUP = "BattleshipAuGroup",
    ---@type string[]
    BOARD_ROWS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" },
    UI = {
        ---@type UiDefaultOpts
        BOARD_DEFAULT_OPTS = {
            height = 20,
            width = 45,
            row = 5,
            col = 10,
        },
        ---@type UiDefaultOpts
        PROMPT_DEFAULT_OPTS = {
            height = 1,
            width = 45,
            row = 27,
            col = 10,
        },
    },
}
