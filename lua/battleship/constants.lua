return {
    BATTLESHIP_AUTO_GROUP = "BattleshipAuGroup",
    BATTLESHIP_NAMESPACE = "BattleshipNamespace",
    ---@type string[]
    BOARD_ROWS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" },
    CHARS_MAP = {
        PIPE = "│",
        DASH = "─",
    },
    UI = {
        ---@type InterfaceOptions
        BOARD_DEFAULT_OPTS = {
            height = 20,
            width = 45,
            row = 5,
            col = 10,
        },
        ---@type InterfaceOptions
        PROMPT_DEFAULT_OPTS = {
            height = 1,
            width = 45,
            row = 27,
            col = 10,
        },
        ---@type InterfaceOptions
        LOG_DEFAULT_OPTS = {
            height = 23,
            width = 30,
            row = 5,
            col = 58,
        },
    },
    SHIPS_NAMES = { [2] = "Destroyer", [3] = "Submarine", [4] = "Battleship", [5] = "Carrier" },
}
